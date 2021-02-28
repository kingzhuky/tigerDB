<template>
  <div>
    <el-row>
      <el-tabs v-model="tabactiveName" @tab-click="handleClick">
        <el-tab-pane label="Cell Type Expression" name="marker">
          <el-col span="8">
            <el-select
              v-model="selectgloclu"
              multiple
              @change="filtergloclu"
              style="width: 100%"
              placeholder="Select Main Lineage"
            >
              <el-option
                v-for="item in gloclures"
                :key="item"
                :label="item"
                :value="item"
              >
              </el-option>
            </el-select>
          </el-col>

          <el-col :span="4" :offset="12">
            <el-input
              v-model="searchinput"
              @change="searchChange"
              placeholder="Input Gene Symbol"
            ></el-input>
          </el-col>

          <br />
          <el-table
            class="tigtablele"
            id="scDiffExpTable"
            ref="singleTable"
            border="false"
            max-height="750"
            :data="tableData"
            @cell-click="heandleclick"
            :cell-style="tableCellStyle"
            :header-cell-class-name="headerStyle"
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
            <span>Low logFC&lt;0</span>
            <span class="heatMapTable--colorbar"></span>
            <span>High logFC&gt;0</span>
          </div>
          <div id="detailinfo">
            <v-celltypedetail
              ref="detailPlot"
              v-show="isShow"
              :gene="clickGene"
              :cancer="cancer"
              :celltype="celltype"
              :gloclu="gloclu"
            ></v-celltypedetail>
          </div>
        </el-tab-pane>
        <el-tab-pane label="Pathway Analysis" name="cluster">
          <v-scpathway
            ref="scpathwayRef"
            :cancer="cancer"
            :gloCluoptions="gloCluoptions"
            tabactiveName="cluster"
          ></v-scpathway>
        </el-tab-pane>
      </el-tabs>
    </el-row>
  </div>
</template>

<script>
import {
  scrollRow,
  gStyle,
  move,
  stop,
  toTarget,
} from "../../../static/js/utils.js";

export default {
  props: {
    cancer: String,
    gloCluoptions: Array,
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
      gloclures: [],
      selectgloclu: [],
      tabactiveName: "marker",
    };
  },

  mounted: function () {
    // this.plot()
    this.reset();
    this.oldcancer = this.cancer;
    this.oldgloclu = this.gloclu;
    for (let gloclu of this.gloCluoptions) {
      this.gloclures.push(gloclu["GlobalCluster"]);
      this.selectgloclu.push(gloclu["GlobalCluster"]);
    }
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
    reset() {
      this.tableData = [];
      this.loadDir = "";
      this.tableDataheader = [];
    },
    plot() {
      if (
        (this.oldcancer !== this.cancer) |
        (this.oldcancer === "") |
        (this.oldgloclu !== this.gloclu) |
        (this.oldgloclu === "")
      ) {
        this.reset();
        this.oldcancer = this.cancer;
        this.oldgloclu = this.gloclu;
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
      let glocluster = column.type;
      switch (glocluster) {
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
    filtergloclu() {
      this.reset();
      this.getTableData(this.loadpage, this.sortCol, this.sortOrder);
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

    //获取表格数据
    getTableData(page, sortCol, sortOrder) {
      this.loading = true;
      this.$http
        .get("/tiger/responseexpvs.php", {
          params: {
            type: "scmarkermat_" + this.cancer,
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
                let new_key = key.replace(".", "_");
                new_row[new_key] = row[key];
              }
              new_rows.push(new_row);
            }
            this.tableData = new_rows; // matrix key .替换为_
            var new_columns = []; // generate header
            for (const column of this.tableDataheader) {
              var col_obj = {};
              col_obj.name = column.split(",").pop();
              col_obj.key = column.replace(".", "_");
              col_obj.type = column.split(",")[0];
              if (
                col_obj.type == "gene" ||
                this.selectgloclu.indexOf(col_obj.type) != -1
              ) {
                new_columns.push(col_obj);
              }
            }
            // console.log(this.selectgloclu)
            this.tableDataheader = new_columns;
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
        this.isShow = true;
        this.clickGene = row["gene"];
        this.celltype = column["label"];
        this.gloclu = column["type"];
        this.$refs.detailPlot.getdatagene(row["gene"]);
        this.$refs.detailPlot.markerPlot(
          row["gene"],
          column["label"],
          column["type"]
        );
        setTimeout(() => {
          toTarget(720);
        }, 300);
      }
    },

    //渲染每个格子的颜色
    tableCellStyle({ row, column }) {
      if (row[column["property"]] === null || column["property"] == "gene") {
        return {
          background: "white",
        };
      }
      var mycolr = gStyle(parseFloat(row[column["property"]]), 2.25);
      return {
        background: mycolr["background"],
        color: mycolr["color"],
      };
    },
    handleClick(tab) {
      this.reset();
      this.tabactiveName = tab.name;
      this.getTableData(1, "", "");
    },
  },
  components: {
    "v-celltypedetail": () => import("./celltypedetail.vue"),
    "v-scpathway": () => import("./scpathway.vue"),
  },
  watch: {
    clickGene() {
      console.log("click");
      this.$nextTick(() => {
        setTimeout(() => {
          toTarget(720);
        }, 300);
      });
    },
  },
};
</script>


<style>
#scDiffExpTable th {
  left: 70px !important;
  height: 140px !important;
}
#tab-cluster,
#tab-marker {
  font-size: 18px;
  height: 40px;
  padding: 0px 10px;
  font-weight: bold !important;
}
</style>
