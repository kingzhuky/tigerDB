<template>
  <div v-loading="loading">
    <el-row v-show="predictshow">
      <div class="geneExp">
        <div
          id="RankScore"
          class="barPlot"
          style="width: 1200px; height: 400px"
        ></div>
      </div>
    </el-row>
    <el-row>
      <p class="card-title">Signature Score Table</p>
      <div>
        <el-table
          id="immuneSigCusTable"
          class="tigtablele"
          border
          max-height="650"
          :data="sigsampletable"
          @cell-click="heandleclick"
          :cell-style="tableCellStyle"
          @sort-change="sortChangeClick"
          style="100%"
        >
          <el-table-column
            v-for="(item, index) in sigsampletableheader"
            :key="item.key"
            :property="item.key"
            :label="item.name"
            :type="item.sigid"
            :sort-orders="['ascending', 'descending']"
            sortable="custom"
            align="center"
            width="80"
          >
          </el-table-column>
          <el-table-column
            property=" "
            label=" "
            align="center"
            width="60"
          ></el-table-column>
          <!-- <el-table-column>
            <template slot-scope="scope">{{
              scope.row[item] === undefined ? "" : scope.row[item].split("_")[0]
            }}</template>
          </el-table-column> -->
        </el-table>
        <div class="geneExp" v-show="isShow">
          <div
            id="sigbarplot"
            class="barPlot"
            style="width: 1200px; height: 400px"
          ></div>
        </div>
      </div>
    </el-row>
    <!-- <el-row v-show="isgroupshow">
            <p class="card-title">Signature Score Table</p>
            <div class="detailimg">
            <el-table
                id="immuneSigTable"
                class="tigtablele"
                border
                max-height="800"
                v-loading="grouploading"
                :data="siggrouptable"
                @cell-click="heandleclick"
                :cell-style="tableCellStyle"
                style="100%"
            >
                <el-table-column
                v-for="(item,index) in siggrouptableheader"
                :key="index"
                :property="item"
                :label="item"
                sortable
                align="center"
                width="80"
                >
                </el-table-column>
            </el-table>
            </div>
        </el-row> -->
    <el-row>
      <!-- <p class="card-title">Signature Score Table</p> -->
      <v-sigdetail
        ref="immuneSigDetail"
        v-show="isShow"
        :sigID="sigID"
      ></v-sigdetail>
    </el-row>
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
    expDataPath: String,
    annoDataPath: String,
    taskuid: String,
  },
  data() {
    return {
      fileList: [],
      sigsampletable: [],
      sigsampletableheader: [],
      siggrouptable: [],
      siggrouptableheader: [],
      showgroup: false,
      resultShow: true,
      loading: false,
      grouploading: false,
      isgroupshow: false,
      sigID: "",
      isShow: false,
      predictshow: false,
    };
  },
  created() {
    // this.analysisData(this.expDataPath,this.annoDataPath,this.taskuid)
  },

  methods: {
    getsampletableData(samplejsonUrl) {
      this.$http
        .get("/tiger/img/" + samplejsonUrl + ".json")
        .then((res) => {
          this.sigsampletable = res.data;
          this.sigsampletableheader = Object.keys(res.data[0]);
          // console.log(this.sigsampletable)
          var new_rows = []; // matrix key .替换为_
          for (const row of this.sigsampletable) {
            var new_row = {};
            for (const key in row) {
              let new_key = key.replace(".", "_");
              new_row[new_key] = row[key];
            }
            new_rows.push(new_row);
          }
          this.sigsampletable = new_rows; // matrix key .替换为_
          var new_columns = []; // generate header
          for (const column of this.sigsampletableheader) {
            var col_obj = {};
            col_obj.name = column.split(",").pop();
            col_obj.key = column.replace(".", "_");
            col_obj.sigid = column.split(",")[0];
            new_columns.push(col_obj);
          }
          this.sigsampletableheader = new_columns;
          // console.log(this.sigsampletableheader);
          var plotdata = this.sigsampletable.map(function (n) {
            return [n["sample_id"], n["Rank Score"]];
          });
          this.draw_chart(
            plotdata.sort(function (a, b) {
              return b[1] - a[1];
            }),
            "RankScore",
            "Rank Score"
          );
          this.predictshow = true;
        })
        .catch((error) => {
          console.log(error);
        });
      this.loading = false;
    },
    getgrouptableData(groupjsonUrl) {
      this.$http
        .get("/tiger/img/" + groupjsonUrl + ".json")
        .then((res2) => {
          this.siggrouptable = res2.data;
          this.siggrouptableheader = Object.keys(res2.data[0]);
          // console.log(siggrouptableheader);
        })
        .catch(function (error) {
          console.log(error);
        });
      this.grouploading = false;
    },

    analysisData(expDataPath, annoDataPath, taskuid) {
      var that = this;
      that.loading = true;
      that.grouploading = true;
      this.$http
        .get("/tiger/2.4.1.sigscoreCustomTable.php", {
          params: {
            expfile: expDataPath,
            annofile: annoDataPath,
            keyid: taskuid,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            let imgpath = res.data.output[0].split(",");
            that.getsampletableData(imgpath[0]);
            if (imgpath[1] === "0") {
              that.grouploading = false;
              that.isgroupshow = false;
            } else {
              that.getgrouptableData(imgpath[1]);
              that.isgroupshow = true;
              that.grouploading = false;
            }
          } else {
            that.resultShow = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
    //点击单个格子
    heandleclick(row, column) {
      this.datatype = "immunescreening";
      if (
        column["type"] !== "sample_id" &&
        column["type"] !== "group" &&
        column["type"] !== "Rank Score"
      ) {
        this.isShow = true;
        this.sigID = column["type"];
        // console.log(this.sigID);
        this.$refs.immuneSigDetail.renewDetail(this.sigID);
        var plotdata = this.sigsampletable.map(function (n) {
          return [n["sample_id"], n[column["property"]]];
        });
        this.draw_chart(
          plotdata.sort(function (a, b) {
            return b[1] - a[1];
          }),
          "sigbarplot",
          column["label"]
        );
        setTimeout(() => {
          toTarget(900);
        }, 200);

        // this.m6aMsg = row["gene"];
        // this.cancerMsg = column["label"];
        // setTimeout(() => { toTarget(820) }, 200);
        // this.$refs.detailPlot.tableDetail(row["gene"]);
        // this.$refs.detailPlot.articleDetail(column["label"]);
      } else {
        this.isShow = false;
      }
    },

    draw_chart(data, id, title) {
      var targetdiv = document.getElementById(id);
      let myChart_mercor = window.echarts.init(targetdiv);
      myChart_mercor.clear();
      let option = {
        tooltip: {
          trigger: "axis",
          axisPointer: {
            type: "shadow",
          },
        },
        xAxis: {
          type: "category",
          axisLabel: {
            rotate: 45,
          },
        },
        yAxis: {
          type: "value",
          name: title,
        },
        series: [
          {
            type: "bar",
            data: data,
          },
        ],
      };

      myChart_mercor.clear();
      myChart_mercor.setOption(option);

      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
    // tableCellStyle({ row, column }) {
    //   if (row[column["label"]] === null) {
    //     return {
    //       background: "white",
    //     };
    //   }
    //   var mycolr = gStyle(
    //     parseFloat(
    //       row[column["label"]] === undefined
    //         ? ""
    //         : row[column["label"]]
    //     ),
    //     2.25
    //   );
    //   return {
    //     background: mycolr["background"],
    //     color: mycolr["color"],
    //   };
    // },
    // tableCellStyle({ row, column }) {
    //   console.log(row[column["property"]] )
    //   if (row[column["property"]] === null || row[column["property"]] === 0 || row[column["property"]] === -0) {
    //     return {
    //       background: "white",
    //     };
    //   }
    //   var mycolr = gStyle(parseFloat(row[column["property"]]), 2.25);
    //   return {
    //     background: mycolr["background"],
    //     color: mycolr["color"],
    //   };
    // },
    sortChangeClick(column) {
      console.log(column.order)
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
      this.sigsampletable.sort(function (a, b) {
        return sortByNumber(a[sortCol], b[sortCol], sortOrder);
      });
    },
  },
  components: {
    "v-sigdetail": () => import("./immuneSigTableDetail.vue"),
  },
};
</script>

<style>
#immuneSigCusTable th {
  left: 70px !important;
  height: 140px !important;
}
#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>