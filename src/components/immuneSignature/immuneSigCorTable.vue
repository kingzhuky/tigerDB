<template>
  <div>
    <div v-show="immuneTabShow" v-loading="loading">
      <el-table
        class="tigtablele"
        id="immuneSigTable"
        ref="singleTable"
        border
        max-height="800"
        :data="tableData"
        @cell-click="heandleclick"
        :cell-style="tableCellStyle"
        @sort-change="sortChangeClick"
        style="100%"
      >
        <el-table-column
          v-for="(item, index ) in tableDataheader"
          :key="index"
          :property="item"
          :label="item"
          :sort-orders="['ascending', 'descending']"
          sortable="custom"
          align="center"
          :width="item === 'SignatureName' ? 160 : 80"
        >
          <template slot-scope="scope">{{
            scope.row[item] === undefined ? "" : scope.row[item].split("_")[0]
          }}</template>
        </el-table-column>
        <el-table-column
          property=" "
          label=" "
          align="center"
          width="120"
        ></el-table-column>
      </el-table>

      <div class="colorbar">
        <span>Negative correlation</span>
        <span class="heatMapTable--colorbar"></span>
        <span>Positive correlation</span>
      </div>
      <div id="logFC">correlation</div>
    </div>

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
  scrollCol,
  toTarget,
  gStyle,
  move,
  stop,
} from "../../../static/js/utils.js";

export default {
  props: {
    gene: { type: String },
  },
  data() {
    return {
      immuneTabShow: false,
      isDisable: false,
      cancer: "",
      tableDataheader: [],
      datatype: "",
      signature: "",
      m6aMsg: "",
      cancerMsg: "",
      loading: false,
      isShow: false,
      loadpage: 1,
      tableData: [],
      search: "",
      loadDir: "",
      path: "",
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
    //获取表格数据
    getTableData() {
      this.isShow = false;
      this.loading = true;
      this.immuneTabShow = true;
      this.$http
        .get("/tiger/immuneSig2.php", {
          params: {
            gene: this.gene.trim().replace(" ", ""),
            condi: "tcga",
          },
        })
        .then((res) => {
          if (res.data.status === 0) {
            this.path = res.data.output[0];
            this.getTableData2(res.data.output[0]);
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    getTableData2(file) {
      this.$http
        .get("/tiger/img/" + file + ".json")
        .then((res) => {
          this.loading = false;
          this.tableData = res.data.filter((item) => {
            if (item["SignatureName"] === "Tertiary lymphoid structures") {
              item["SignatureName"] = "TLS";
            } else if (
              item["SignatureName"] ===
              "Tertiary lymphoid structures in melanoma"
            ) {
              item["SignatureName"] = "TLS-melanoma";
            }
            return item;
          });
          this.tableDataheader = Object.keys(res.data[0]).filter(
            (item) => item != "SignatureID"
          );
        })
        .catch((error) => {
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
    heandleclick(row, column) {
      this.datatype = "expression";
      if (column["label"] !== "") {
        this.isShow = true;
        this.m6aMsg = this.gene.trim();
        this.signature = row["SignatureID"];
        this.cancerMsg = column["label"];
        this.$refs.detailPlot.Plot(
          this.gene.trim(),
          column["label"],
          row["SignatureID"]
        );
        this.$refs.detailPlot.artivcleDetail(row["SignatureID"]);
        setTimeout(() => {
          toTarget(820);
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
        color: mycolr["color"],
      };
    },
    sortChangeClick(column) {
      var sortCol = column.prop;
      var sortOrder = column.order;
      function sortByNumber(obj1, obj2, index) {
        if (obj1 === undefined) {
          return 1;
        } else if (obj2 === undefined) {
          return -1;
        }
        if (index === "descending") {
          return obj2 - obj1;
        } else if (index === "ascending") {
          return obj1 - obj2;
        } else {
          return 0;
        }
      }
      this.tableData.sort(function (a, b) {
        return sortByNumber(a[sortCol].split("_")[0], b[sortCol].split("_")[0], sortOrder);
      });
    },
  },
  components: {
    "v-immuneSigdetail": () => import("./immuneSigCorTabledetail.vue"),
  },
};
</script>


<style>
#immuneSigTable th {
  left: 35px !important;
  height: 100px !important;
}

#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>
