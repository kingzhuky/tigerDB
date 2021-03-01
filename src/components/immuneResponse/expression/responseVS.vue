<template>
  <div>
    <el-row>
      <el-col :span="4" :offset="20">
        <el-autocomplete
          v-model="searchinput"
          placeholder="Please Input Gene Symbol"
          :fetch-suggestions="querySearchAsync"
          @change="searchChange"
          @keyup.enter.native="searchChange"
        ></el-autocomplete>
      </el-col>
    </el-row>
    <br />

    <el-table
      class="tigtablele"
      id="responseTable"
      ref="singleTable"
      border
      max-height="800"
      :data="tableData"
      @cell-click="heandleclick"
      :cell-style="tableCellStyle"
      v-loadmore="tabelloadmore"
      v-loadlast="tableloadlast"
      v-loading="loading"
      :header-cell-class-name="headerStyle"
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
        :label="item"
        sortable="custom"
        align="center"
        width="80"
        :property="item"
      ></el-table-column>
      <el-table-column
        property=" "
        label=" "
        align="center"
        width="120"
      ></el-table-column>
      <el-table-column
        property=" "
        label=" "
        align="center"
        width="120"
      ></el-table-column>
    </el-table>

    <div class="colorbar">
      <span>Non-Response</span>
      <span class="heatMapTable--colorbar"></span>
      <span>Response</span>
    </div>

    <!-- <button @click="scrollCol">scrollCol</button> -->

    <!-- 详细页显示与否 -->
    <v-expdetail
      ref="detailPlot"
      v-show="isShow"
      :datatype="datatype"
      :gene="m6aMsg"
      :cancer="cancerMsg"
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
} from "../../../../static/js/utils.js";

//import{getColumn2} from "../../public/pubjs.js"

export default {
  data() {
    return {
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
    };
  },

  mounted: function () {
    this.getColumn("tablecolumn", "expresponse");
    //var checkExist =getColumn2("tablecolumn", "expresponse");
    //console.log(checkExist.status)
    this.getTableData("expresponse", 1, "", "");
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
            //console.log(res.data.list);
            this.tableDataheader = res.data.list;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
    sortChangeClick(column, prop, order) {
      this.loadDir = "";
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.loadpage = 1;
      this.tableData = [];
      this.getTableData(
        "expresponse",
        this.loadpage,
        column.prop,
        this.sortOrder
      );
    },
    headerStyle({ column }) {
      let cancer = column.label.split("-")[0];
      switch (cancer) {
        case "Melanoma":
          return "melanoma";
        case "GBM":
          return "gbm";
        case "RCC":
          return "rcc";
        case "nonsqNSCLC":
          return "nsclc";
        case "LUSC":
          return "lusc";
        case "STAD":
          return "stad";
        default:
          return "defalutColor";
      }
    },

    //顶部加载更多
    tableloadlast() {
      this.loadDir = "up";
      if (this.loading == false && this.loadpage > 1) {
        this.loading = true;
        this.loadpage = this.loadpage - 1;
        this.getTableData(
          "expresponse",
          this.loadpage,
          this.sortCol,
          this.sortOrder
        );
        if (this.loadpage > 1) {
          scrollRow("responseTable", 400);
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
          "expresponse",
          this.loadpage,
          this.sortCol,
          this.sortOrder
        );
        scrollRow("responseTable", 780);
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

    searchChange() {
      this.loading = true;
      this.loadDir = "";
      this.tableData = [];
      this.loadpage = 1;
      this.sortCol = "";
      this.sortOrder = "";
      this.getTableData("expresponse", this.loadpage, "", "");
    },

    //点击单个格子
    heandleclick(row, column) {
      this.datatype = "expression";
      if (column["label"] !== "" && row[column["label"]] !== null) {
        this.isShow = true;
        this.m6aMsg = row["gene"];
        this.cancerMsg = column["label"];
        this.$refs.detailPlot.Plot(row["gene"], column["label"]);
        this.$refs.detailPlot.getSampleDetail(column["label"]);
        this.$refs.detailPlot.getGeneDetail(row["gene"]);
        setTimeout(() => {
          toTarget(620);
        }, 200);
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
      };
    },
  },
  components: {
    "v-expdetail": () => import("./expdetail.vue"),
  },
};
</script>


<style>
</style>
