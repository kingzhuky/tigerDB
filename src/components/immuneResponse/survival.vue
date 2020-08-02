<template>
  <div>
    <el-row>
      <el-col :span="4" :offset="20">
        <el-autocomplete
          v-model="searchinput"
          placeholder="Please Input Gene Symbol"
          :fetch-suggestions="querySearchAsync"
          @change="searchChange"
        ></el-autocomplete>
      </el-col>
    </el-row>
    <br />
<br />
    <el-table
      class="wertable"
      id="survivaltable"
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
      <el-table-column fixed property="gene" label align="center" width="110" id="geneCol"></el-table-column>

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
      <span>Good Prognosis</span>
      <span class="heatMapTable--colorbar"></span>
      <span>Bad Prognosis</span>
    </div>

    <!-- <button @click="scrollCol">scrollCol</button> -->

    <!-- 详细页显示与否 -->
    <v-survivaldetail
      ref="detailPlot"
      v-show="isShow"
      :datatype="datatype"
      :gene="m6aMsg"
      :cancer="cancerMsg"
    ></v-survivaldetail>
  </div>
</template>

<script>
import {
  scrollRow,
  scrollCol,
  toTarget,
  gStyle2,
  move,
  stop,
} from "../../../static/js/utils.js";

export default {
  data() {
    return {
      cancer: "",
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
          value: "UCEC",
          label: "UCEC",
        },
        {
          value: "UCS",
          label: "UCS",
        },
      ],
      datatype: "",
      m6aMsg: "",
      cancerMsg: "",
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
    this.getColumn("tablecolumn", "survival");
    this.getTableData("survival", 1, "", "");
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
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.loadpage = 1;
      this.tableData = [];
      this.getTableData("survival", this.loadpage, column.prop, column.order);
    },
    headerStyle({ row, column, rowIndex, columnIndex }) {
      let cancer = column.label.split("_")[0];
      switch (cancer) {
        case "Melanoma":
          return "melanoma";
          break;
        case "GBM":
          return "gbm";
          break;
        case "ccRCC":
          return "ccRCC";
          break;
        case "Renal":
          return "Renal";
          break;
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
          "survival",
          this.loadpage,
          this.sortCol,
          this.sortOrder
        );
        if (this.loadpage > 1) {
          scrollRow("survivaltable", 400);
          this.loading = false;
        }
      }
    },

    //到底部加载更多
    tabelloadmore() {
      this.loadDir = "down";
      if (this.loading == false) {
        this.loading = true;
        this.loadpage = this.loadpage + 1;
        this.getTableData(
          "survival",
          this.loadpage,
          this.sortCol,
          this.sortOrder
        );
        scrollRow("survivaltable", 780);
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
      this.tableData = [];
      this.loadpage = 1;
      this.sortCol = "";
      this.sortOrder = "";
      this.getTableData("survival", this.loadpage, "", "");
    },

    //点击单个格子
    heandleclick(row, column, cell, event) {
      this.datatype = "survival";
      if (column["label"] !== "") {
        this.isShow = true;
        this.m6aMsg = row["gene"];
        this.cancerMsg = column["label"];
        this.$refs.detailPlot.surPlot(row["gene"], column["label"]);
        this.$refs.detailPlot.getSampleDetail(column["label"]);
        //this.$refs.detailPlot.tableDetail("survival", 1, "");
        toTarget(820);
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column, rowIndex, columnIndex }) {
      if (row[column["label"]] === null) {
        return {
          background: "white",
        };
      }
      var mycolr = gStyle2(parseFloat(row[column["label"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"],
      };
    },
  },
  components: {
    "v-survivaldetail": () => import("./survivalDetail.vue"),
  },
};
</script>


<style>
</style>
