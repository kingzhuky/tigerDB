<template>
  <div>
    <el-card id="readmeCard">
      <el-row id="readme">Readme:</el-row>
      1.The integration of <span class="readmeEmp">CRISPR Screen</span> and <span class="readmeEmp">RNAi Screen</span> shows the correlation
      between genes and immunity in cell experiments.
      <br />2.Click cell of table to get detailed Screen data information and gene-related
      drug information.
    </el-card>
    <el-card>
      <el-col :span="4" :offset="20">
        <el-autocomplete
          v-model="searchinput"
          placeholder="Please Input Gene Symbol"
          :fetch-suggestions="querySearchAsync"
          @change="searchChange"
          @keyup.enter.native="searchChange"
        ></el-autocomplete>
      </el-col>

      <br />

      <el-table
        class="tigtablele"
        id="tableScreenTable"
        ref="singleTable"
        border
        max-height="800"
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
          fixed
          property="gene"
          label
          align="center"
          width="110"
          id="geneCol"
        ></el-table-column>

        <el-table-column
          v-for="(item, index) in tableDataheader"
          :key="index"
          :property="item"
          :label="item"
          sortable
          align="center"
          width="80"
        ></el-table-column>
        <el-table-column
          property=" "
          label=" "
          align="center"
          width="120"
        ></el-table-column>
      </el-table>

      <div class="colorbar">
        <span>Sensitivity</span>
        <span class="heatMapTable--colorbar"></span>
        <span>Resistance</span>
      </div>
    </el-card>

    <!-- 详细页显示与否 -->
    <v-immuneScreendetail
      ref="detailPlot"
      id="detailinfo"
      v-show="isShow"
      :datatype="datatype"
      :gene="m6aMsg"
      :cancer="cancerMsg"
      :bardata="bardata"
    ></v-immuneScreendetail>
  </div>
</template>

<script>
import {
  scrollRow,
  scrollCol,
  gStyle,
  move,
  stop,
  toTarget,
} from "../../static/js/utils.js";

export default {
  data() {
    return {
      isDisable: "",
      cancer: "",
      datatype: {
        type: String,
      },
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
      tableDataheader: [],
      bardata: [],
    };
  },

  mounted: function () {
    this.getColumn("tablecolumn", "immunescreening");
    this.getTableData("immunescreening", 1, "", "");
  },

  watch: {
    cancer() {
      switch (this.cancer) {
        case "KIRP":
          scrollCol("tableScreenTable", 100);
          break;
        case "GBM":
          scrollCol("tableScreenTable", 1000);
          break;
        default:
          scrollCol("tableScreenTable", 0);
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
    },
  },

  methods: {
    getColumn(tabl, mycolumn) {
      this.$http
        .get("/tiger/tablecolumn.php", {
          params: {
            tabl: tabl,
            mycolumn: mycolumn,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.tableDataheader = res.data.list;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
    sortChangeClick(column) {
      this.loadDir = "";
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.loadpage = 1;
      this.tableData = [];
      this.getTableData(
        "immunescreening",
        this.loadpage,
        column.prop,
        column.order
      );
    },

    //顶部加载更多
    tableloadlast() {
      this.loadDir = "up";
      if (this.loading == false && this.loadpage > 1) {
        this.loading = true;
        this.loadpage = this.loadpage - 1;
        this.getTableData(
          "immunescreening",
          this.loadpage,
          this.sortCol,
          this.sortOrder
        );
        if (this.loadpage > 1) {
          scrollRow("tableScreenTable", 400);
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
        this.getTableData(
          "immunescreening",
          this.loadpage,
          this.sortCol,
          this.sortOrder
        );
        scrollRow("tableScreenTable", 780);
      }
    },

    //获取表格数据
    getTableData(type, page, sortCol, sortOrder) {
      this.$http
        .get("/tiger/responseexpvs.php", {
          params: {
            type: type,
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
            }
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    //搜索
    searchChange() {
      this.loading = true;
      this.loadDir = "";
      this.tableData = [];
      this.loadpage = 1;
      this.getTableData(
        "immunescreening",
        this.loadpage,
        this.sortCol,
        this.sortOrder
      );
    },

    //点击单个格子
    heandleclick(row, column) {
      this.datatype = "immunescreening";
      if (column["label"] !== "") {
        this.isShow = true;
        this.m6aMsg = row["gene"];
        this.cancerMsg = column["label"];
        this.bardata = row
        setTimeout(() => {
          toTarget(720);
        }, 300);
        // this.$refs.detailPlot.tableDetail(row["gene"]);
        this.$refs.detailPlot.articleDetail(column["label"]);
        this.$refs.detailPlot.draw_chart(row, this.m6aMsg, this.cancerMsg);
      }
    },
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
      };
    },
  },
  components: {
    "v-immuneScreendetail": () => import("./immuneScreendetail.vue"),
  },
};
</script>


<style>
#tableScreenTable th {
  left: 90px !important;
  height: 180px !important;
}
div#readmeCard {
  font-size: 16px;
  line-height: 22px;
  border-color: rgb(20, 146, 140);
  margin-bottom: 20px;
}
div#Log2FC {
  text-align: center;
}
</style>