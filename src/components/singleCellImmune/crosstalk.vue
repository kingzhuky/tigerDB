<template>
  <div>
    <el-row>
      <el-col :span="4" :offset="20">
        <el-input
          v-model="searchinput"
          @change="searchChange"
          placeholder="Input Cell Type"
        ></el-input>
      </el-col>
    </el-row>
    <br />
    <el-table
      class="tigtablele"
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
        v-for="(item, index) in tableDataheader"
        :key="index"
        :property="item.key"
        :label="item.name"
        :type="item.type"
        sortable="custom"
        :sort-orders="['ascending', 'descending', null]"
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
      <span>Less Effect</span>
      <span class="crossTable--colorbar"></span>
      <span>More Effect</span>
    </div>
    <v-crosstalkdetail
      ref="detailPlot"
      v-show="isShow"
      :cancer="cancer"
      :celltype="celltype"
      :celltype2="clickGene"
      :gloclu="gloclu"
    ></v-crosstalkdetail>
  </div>
</template>

<script>
import {
  scrollRow,
  toTarget,
  gStyle,
  move,
  stop,
  onesidecolor,
} from "../../../static/js/utils.js";

export default {
  props: {
    cancer: String,
    subClu: Array,
    subClucoptions: Array,
  },
  data() {
    return {
      clickGene: "",
      loading: true,
      isShow: false,
      loadpage: 1,
      tableData: [],
      searchinput: "",
      loadDir: "",
      sortCol: "",
      sortOrder: "",
      tableDataheader: [],
      oldcancer: "",
      celltype: "",
      gloclu: "",
    };
  },

  mounted: function () {
    this.oldcancer = this.cancer;
    this.getTableData(1, "", "");
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
    plot() {
      if ((this.oldcancer !== this.cancer) | (this.oldcancer === "")) {
        this.reset();
        this.oldcancer = this.cancer;
        this.getTableData(1, "", "");
      }
    },
    sortChangeClick(column) {
      this.loadDir = "";
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.loadpage = 1;
      this.tableData = [];
      this.getTableData(this.loadpage, column.prop, column.order);
    },
    headerStyle({ column }) {
      let cancer = column.type;
      switch (cancer) {
        case "All":
          return "scglo-all";
        case "Tcell":
          return "scglo-g1";
        case "Myeloid":
          return "scglo-g2";
        case "Bcell":
          return "scglo-g3";
        case "CD4":
          return "scglo-g4";
        case "CD8":
          return "scglo-g5";
        case "gene":
          return "";
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
        this.getTableData(this.loadpage, this.sortCol, this.sortOrder);
        if (this.loadpage > 1) {
          // console.log(this.loadpage);
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
      this.loading = true;
      this.$http
        .get("/tiger/responseexpvs.php", {
          params: {
            type: "sccrosstalk_" + this.cancer,
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
            var new_rows = []; // matrix key .替换为_
            for (const row of this.tableData) {
              var new_row = {};
              for (const key in row) {
                let new_key = key;
                if (new_key === "gene") {
                  new_row[new_key] = row[key];
                } else {
                  new_row[new_key] = row[key].split("_")[0];
                }
              }
              new_rows.push(new_row);
            }
            this.tableData = new_rows; // matrix key .替换为_
            var new_columns = []; // generate header
            for (const column of this.tableDataheader) {
              var col_obj = {};
              col_obj.name = column.split(",").pop();
              col_obj.key = column;
              col_obj.type = column.split(",")[0];
              // console.log(col_obj)
              new_columns.push(col_obj);
            }
            this.tableDataheader = new_columns;
            // console.log(new_rows)
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
        this.celltype = column["label"];
        this.gloclu = column["type"];
        this.$refs.detailPlot.markerPlot(row["gene"], column["label"]);
        setTimeout(() => {
          toTarget(820);
        }, 200);
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column }) {
      if (row[column["property"]] === null || column["property"] == "gene") {
        return {
          background: "white",
        };
      }
      var mycolr = onesidecolor(0, 60, parseFloat(row[column["property"]]));
      return {
        background: mycolr["background"],
        color: mycolr["color"],
      };
    },
  },
  components: {
    "v-crosstalkdetail": () => import("./crosstalkdetail.vue"),
  },
};
</script>


<style>
#scDiffExpTable th {
  left: 70px !important;
  height: 140px !important;
}
</style>
