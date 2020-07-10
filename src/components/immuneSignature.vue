<template>
  <div>
    <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
      1. Input genes to analyze the immune signature of pan-cancer species.
      <br />2. Correlation heat map shows the correlation between user-defined genes between pan-cancer species and immune signatures.
      <br />3. Click the correlation heatmap to display the detailed correlation scatter plot.
      </el-card>
    <el-card class="anaCard" id="inputCard">
      
      <el-row  >
        <el-col :span="10" :offset="3">
            <span class="label" id="immuinput">Input Gene/Geneset (eg. CD274 OR CD274,CD3D)</span>
            </el-col>
          </el-row>
       <br />
      <el-row >
        <el-col :span="10" :offset="3">
          
          <el-row>
            <el-input v-model="gene" placeholder="SEMA3F"></el-input>
          </el-row>
        </el-col>

        <el-col :span="6" :offset="1">
          <el-row >
            <el-button
              id="immusignatureplot"
              v-on:click="signatureDiffPlot"
              :disabled="isDisable"
            >Submit</el-button>
          </el-row>
        </el-col>
      </el-row>
    </el-card>

    <div v-show="immuneTabShow" v-loading="loading">
      <el-card>
        <el-row>
          <el-col :span="4" :offset="20">
            <el-input v-model="search" placeholder="Input Signature ID"></el-input>
          </el-col>
        </el-row>
        <br />

        <el-table
          class="wertable"
          id="immuneSigTable"
          ref="singleTable"
          border
          max-height="800"
          :data="tableData.filter(data => !search || data.Signature.toLowerCase().includes(search.toLowerCase()))"
          @cell-click="heandleclick"
          :cell-style="tableCellStyle"
          style="100%"
        >
          <el-table-column
            v-for="(item,index) in tableDataheader"
            :key="index"
            :property="item"
            :label="item"
            sortable
            align="center"
            width="80"
          >
            <template
              slot-scope="scope"
            >{{ scope.row[item]===undefined ? '': scope.row[item].split('_')[0] }}</template>
          </el-table-column>
          <el-table-column property=" " label=" " align="center" width="120"></el-table-column>
        </el-table>

        <div class="colorbar">
          <span>Negative correlation</span>
          <span class="heatMapTable--colorbar"></span>
          <span>Positive correlation</span>
        </div>
        <div id="logFC">correlation</div>
      </el-card>
    </div>
    <!-- <button @click="scrollCol">scrollCol</button> -->

    <!-- 详细页显示与否 -->
    <v-immuneSigdetail
      ref="detailPlot"
      v-show="isShow"
      :sign="signature"
      :datatype="datatype"
      :gene="m6aMsg"
      :cancer="cancerMsg"
      :path="path"
    ></v-immuneSigdetail>
  </div>
</template>

<script>
import {
  scrollRow,
  scrollCol,
  getTableData,
  toTarget,
  gStyle,
  move,
  stop
} from "../../static/js/utils.js";

export default {
  data() {
    return {
      immuneTabShow: false,
      isDisable: false,
      cancer: "",
      tableDataheader: [
      ],
      datatype: "",
      signature: "",
      m6aMsg: "",
      cancerMsg:"",
      loading: false,
      isShow: false,
      loadpage: 1,
      tableData: [],
      search: "",
      loadDir: "",
      gene: "CD274,CD3D",
      path: ""
    };
  },

  watch: {
    cancer() {
      switch (this.cancer) {
        case "KIRP":
          scrollCol("immuneSigTable", 100);
          break;
        case "GBM":
          scrollCol("immuneSigTable", 1000);
          break;
        default:
          scrollCol("immuneSigTable", 0);
      }
    },
    loading() {
      switch (this.loading) {
        case true:
          stop();
          break;
        case false:
          move();
          break;
      }
    }
  },

  // mounted() {
  //   this.getColumn("tablecolumn", "tcga");
  // },

  methods: {
   getColumn(tabl, mycolumn) {
      this.$http
        .get("/tiger/tablecolumn.php", {
          params: {
            tabl: tabl,
            mycolumn: mycolumn
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            //console.log(res.data.list);
            this.tableDataheader = res.data.list;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
    //获取表格数据
    getTableData(type, page) {
      this.loading = true;
      this.immuneTabShow = true;
      this.$http
        .get("/tiger/immuneSig.php", {
          params: {
            gene: this.gene.trim()
          }
        })
        .then(res => {
          if (res.data.status === 0) {
            this.path = res.data.output[0];
            this.getTableData2(res.data.output[0]);
          }
        })
        .catch(error => {
          console.log(error);
        });
    },

    getTableData2(file) {
      this.$http
        .get("/tiger/img/" + file + ".json")
        .then(res => {
          this.loading = false;
          this.tableData = res.data;
          this.tableDataheader=Object.keys(res.data[0])
        })
        .catch(error => {
          console.log(error);
        });
    },

    //搜索
    signatureDiffPlot() {
      this.tableData = [];
      this.loadpage = 1;
      this.getTableData("expresponse", this.loadpage);
    },

    //点击单个格子
    heandleclick(row, column, cell, event) {
      this.datatype = "expression";
      if (column["label"] !== "") {
        this.isShow = true;
        this.m6aMsg = this.gene.trim();
        this.signature = row["Signature"];
        this.cancerMsg = column["label"];
        this.$refs.detailPlot.Plot(
          this.gene.trim(),
          column["label"],
          row["Signature"]
        );
        this.$refs.detailPlot.artivcleDetail(row["Signature"]);
        toTarget(820);
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column, rowIndex, columnIndex }) {
      if (row[column["label"]]===null){
        return {
            background: "white"
          }
      }
      var mycolr = gStyle(
        parseFloat(
          row[column["label"]] === undefined
            ? ""
            : row[column["label"]].split("_")[0]
        ),
        2.25
      );
      return {
        background: mycolr["background"],
        color: mycolr["color"]
      };
    }
  },
  components: {
    "v-immuneSigdetail": () => import("./immuneSigdetail.vue")
  }
};
</script>


<style>
@import "./immuneResponse/style.css";

#immuneSigTable th {
  left: 35px !important;
  height: 70px !important;
}


#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>
