<template>
  <div>
    <div v-show="immuneTabShow" v-loading="loading">
      <el-card>
        <el-table
          class="tigtablele"
          id="survivaltable"
          ref="singleTable"
          border
          max-height="900"
          :data="tableData"
          @cell-click="heandleclick"
          :cell-style="tableCellStyle"
          @sort-change="sortChangeClick"
          style="100%"
        >
          <el-table-column
            v-for="item in tableDataheader"
            :key="item"
            :property="item"
            :label="item"
            :sort-orders="['ascending', 'descending']"
            sortable="custom"
            align="center"
            :width="item === 'SignatureName' ? 160 : 80"
          >
            <!-- <template
              slot-scope="scope"
            >{{ scope.row[item]===undefined ? '': scope.row[item].split('_')[0] }}</template> -->
          </el-table-column>
          <el-table-column
            property=" "
            label=" "
            align="center"
            width="120"
          ></el-table-column>
        </el-table>

        <div class="colorbar">
          <span class="crossTable--colorbar"></span>
          <span>Better Performance</span>
        </div>
        <div id="logFC">AUC</div>
      </el-card>
    </div>

    <!-- 详细页显示与否 -->
    <v-immuneSigResdetail
      ref="detailPlot"
      v-show="isShow"
      :sign="signature"
      :signame="signame"
      :datatype="datatype"
      :dataset="datasetid"
      :path="path"
    ></v-immuneSigResdetail>
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
      datasetid: "",
      loading: false,
      isShow: false,
      loadpage: 1,
      tableData: [],
      search: "",
      loadDir: "",
      path: "",
      signame: "",
    };
  },

  watch: {
    cancer() {
      switch (this.cancer) {
        case "KIRP":
          scrollCol("immuneSigResTable", 100);
          break;
        case "GBM":
          scrollCol("immuneSigResTable", 1000);
          break;
        default:
          scrollCol("immuneSigResTable", 0);
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
    signatureDiffPlot() {
      this.tableData = [];
      this.loadpage = 1;
      this.getTableData();
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
        .get("/tiger/immuneSig.php", {
          params: {
            gene: this.gene.trim().replace(" ", ""),
            condi: "response",
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
          // console.log(this.tableDataheader)
        })
        .catch((error) => {
          console.log(error);
        });
    },

    //点击单个格子
    heandleclick(row, column) {
      this.datatype = "response";
      if (column["label"] !== "") {
        this.isShow = true;
        this.signature = row["SignatureID"];
        this.signame = row["SignatureName"];
        this.datasetid = column["label"];
        this.$refs.detailPlot.gettable(
          this.gene,
          row["SignatureID"],
          column["label"]
        );
        setTimeout(() => {
          toTarget(820);
        }, 200);
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column }) {
      if (row[column["label"]] === undefined || row[column["label"]] === 0) {
        return {
          background: "white",
        };
      }
      var mycolr = gStyle(
        parseFloat(
          row[column["label"]] === undefined ? "" : row[column["label"]]
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
        return sortByNumber(a[sortCol], b[sortCol], sortOrder);
      });
    },
  },
  components: {
    "v-immuneSigResdetail": () => import("./immuneSigbioresponsedetail.vue"),
  },
};
</script>


<style>
/* #immuneSigResTable th {
  left: 35px !important;
  height: 70px !important;
} */

#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>
