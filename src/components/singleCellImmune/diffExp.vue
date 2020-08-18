<template>
  <div>
    <el-row>
      <el-col :span="10" :offset="2">
     <div id="singleCellTitle"> Tumor vs Normal / Response vs Non-response</div>
      </el-col>
      <el-col :span="4" :offset="8">
        <el-autocomplete
          v-model="searchinput"
          placeholder="Please Input Gene Symbol"
          :fetch-suggestions="querySearchAsync"
          @change="searchChange"
        ></el-autocomplete>
      </el-col>
    </el-row>
    <br />
    <el-table
      class="wertable"
      id="scDiffExpTable"
      ref="singleTable"
      border
      max-height="750"
      :data="tableData"
      @cell-click="heandleclick"
      :cell-style="tableCellStyle"
      v-loadmore="tabelloadmore"
      v-loadlast="tableloadlast"
      v-loading="loading"
      @sort-change="sortChangeClick"
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
      ></el-table-column>
      <el-table-column property=" " label=" " align="center" width="120"></el-table-column>
    </el-table>

    <div class="colorbar">
      <span>Low logFC&lt;0</span>
      <span class="heatMapTable--colorbar"></span>
      <span>High logFC&gt;0</span>
    </div>

    <!-- <button @click="scrollCol">scrollCol</button> -->

    <!-- 详细页显示与否 -->
    <v-expdetail
      ref="detailPlot"
      v-show="isShow"
      :gene="clickGene"
      :cancer="cancer"
      :gloclu="gloclu"
      :subClu="subClu"
      :subClucoptions="subClucoptions"
    ></v-expdetail>
  </div>
</template>

<script>
import {
  scrollRow,
  scrollCol,
  toTarget,
  gStyle,
  move,
  stop,
} from "../../../static/js/utils.js";

export default {
  props: {
    cancer: String,
    gloclu: String,
    subClu: Array,
    subClucoptions: Array,
  },
  data() {
    return {
      cancer: "",
      clickGene: "",
      wercorcancer_data: [
        {
          value: "ACC",
          label: "ACC",
        },
        {
          value: "BLCA",
          label: "BLCA",
        },
        {
          value: "BRCA",
          label: "BRCA",
        },
        {
          value: "CESC",
          label: "CESC",
        },
        {
          value: "CHOL",
          label: "CHOL",
        },
        {
          value: "COAD",
          label: "COAD",
        },
        {
          value: "DLBC",
          label: "DLBC",
        },
        {
          value: "ESCA",
          label: "ESCA",
        },
        {
          value: "GBM",
          label: "GBM",
        },
        {
          value: "HNSC",
          label: "HNSC",
        },
        {
          value: "KICH",
          label: "KICH",
        },
        {
          value: "KIRC",
          label: "KIRC",
        },
        {
          value: "KIRP",
          label: "KIRP",
        },
        {
          value: "LIHC",
          label: "LIHC",
        },
        {
          value: "LAML",
          label: "LAML",
        },
        {
          value: "LGG",
          label: "LGG",
        },
        {
          value: "LUAD",
          label: "LUAD",
        },
        {
          value: "LUSC",
          label: "LUSC",
        },
        {
          value: "MESO",
          label: "MESO",
        },
        {
          value: "OV",
          label: "OV",
        },
        {
          value: "PAAD",
          label: "PAAD",
        },
        {
          value: "PCPG",
          label: "PCPG",
        },
        {
          value: "READ",
          label: "READ",
        },
        {
          value: "SKCM",
          label: "SKCM",
        },
        {
          value: "SARC",
          label: "SARC",
        },
        {
          value: "STAD",
          label: "STAD",
        },
        {
          value: "TGCT",
          label: "TGCT",
        },
        {
          value: "THCA",
          label: "THCA",
        },
        {
          value: "THYM",
          label: "THYM",
        },
        {
          value: "TNBC",
          label: "TNBC",
        },
        {
          value: "UCEC",
          label: "UCEC",
        },
        {
          value: "UCS",
          label: "UCS",
        },
      ],
      m6aMsg: {
        type: String,
      },
      cancerMsg: {
        type: String,
      },
      loading: true,
      isShow: false,
      loadpage: 1,
      tableData: [],
      searchinput: "",
      loadDir: "",
      sortCol: "",
      sortOrder: "",
      oldcancer: "",
      oldgloclu: "",
      tableDataheader: [],
    };
  },

  mounted: function () {
    this.oldcancer = this.cancer;
    this.oldgloclu = this.gloclu;
    this.getTableData(1, "", "");
    console.log(this.subClu);
  },

  watch: {
    loading() {
      switch (this.loading) {
        case true:
          stop();
          break;
        case false:
          move();
          break;
      }
    },
  },

  methods: {
    querySearchAsync(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.searchinput,
            species: "Human",
          },
        })
        .then((res) => {
          cb(res.data.datasetinfo);
        });
    },

    plot() {
      if (
        (this.oldcancer !== this.cancer) |
        (this.oldcancer === "") |
        (this.oldgloclu !== this.gloclu) |
        (this.oldgloclu === "")
      ) {
        this.oldcancer = this.cancer;
        this.oldgloclu = this.gloclu;
        this.getTableData(1, "", "");
      }
    },

    sortChangeClick(column, prop, order) {
      console.log(column.prop, column.order);
      this.loadDir = "";
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.loadpage = 1;
      this.tableData = [];
      this.getTableData(this.loadpage, column.prop, column.order);
    },

    //顶部加载更多
    tableloadlast() {
      this.loadDir = "up";
      if (this.loading == false && this.loadpage > 1) {
        this.loading = true;
        this.loadpage = this.loadpage - 1;
        this.getTableData(this.loadpage, this.sortCol, this.sortOrder);
        if (this.loadpage > 1) {
          console.log(this.loadpage);
          scrollRow("scDiffExpTable", 400);
          this.loading = false;
        }
      }
    },

    //底部加载更多
    tabelloadmore() {
      this.loadDir = "down";
      if (this.loading == false) {
        this.loading = true;
        this.loadpage = this.loadpage + 1;
        this.getTableData(this.loadpage, this.sortCol, this.sortOrder);
        scrollRow("scDiffExpTable", 780);
      }
    },
    reset() {
      this.tableData = [];
      this.loadDir = "";
      this.tableDataheader = [];
    },

    //获取表格数据
    getTableData(page, sortCol, sortOrder) {
      this.$http
        .get("/tiger/responseexpvs.php", {
          params: {
            type: "singlecelldiff_" + this.cancer + "_" + this.gloclu,
            draw: page,
            search: this.searchinput.trim(),
            start: (page - 1) * 20,
            length: 20,
            sortcol: sortCol,
            sortorder: sortOrder === null ? "None" : sortOrder,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.loading = false;
            if (this.loadDir === "down") {
              this.tableData = this.tableData.slice(
                this.tableData.length - 20,
                this.tableData.length
              );
              res.data.list.forEach((n) => {
                this.tableData.push(n);
              });
            } else if (this.loadDir === "up") {
              if (res.data.list.length !== 0) {
                let old = this.tableData.slice(0, 20);
                this.tableData = res.data.list;
                old.forEach((n) => {
                  this.tableData.push(n);
                });
              }
            } else {
              res.data.list.forEach((n) => {
                this.tableData.push(n);
              });
              this.tableDataheader = Object.keys(res.data.list[0]);
            }
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    searchChange() {
      this.loading = true;

      this.loadDir = "";
      this.tableData = [];
      this.loadpage = 1;
      this.getTableData(this.loadpage, "", "");
    },

    //点击单个格子
    heandleclick(row, column) {
      if (column["label"] !== "gene") {
        this.subClu = this.subClucoptions;
        this.isShow = true;
        this.clickGene = row["gene"];
        this.$refs.detailPlot.genePlot(row["gene"]);
        //this.$refs.detailPlot.evoluPlot(row["gene"]);
        //this.$refs.detailPlot.tableDetail("expression", 1, "");
        toTarget(820);
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column }) {
      if (row[column["label"]] === null) {
        return {
          background: "white",
        };
      }
      var mycolr = gStyle(parseFloat(row[column["label"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"],
        cursor: mycolr["cursor"],
      };
    },
  },
  components: {
    "v-expdetail": () => import("./expdetail.vue"),
  },
};
</script>


<style>
#scDiffExpTable th {
  left: 70px !important;
  height: 140px !important;
}
div#singleCellTitle {
    font-size: 20px;
    font-weight: bold;
    padding-top: 10px;
}
</style>
