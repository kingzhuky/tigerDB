<template>
  <div>
    <el-row type="flex" justify="space-around">
      <el-col :span="4">
        <el-tree
          :data="data"
          default-expand-all
          :props="defaultProps"
          @node-click="handleNodeClick"
        ></el-tree
      ></el-col>
      <el-col :span="10" v-loading="picloading">
        <el-row>
          <div id="scumap_celltype" style="width: 600px; height: 400px"></div>
        </el-row>
        <el-row>
          <div id="scumap_celltype2" style="width: 600px; height: 400px"></div>
        </el-row>
      </el-col>
      <el-col :span="8">
        <el-tabs v-model="tabactiveName" @tab-click="handleClick">
          <el-tab-pane label="Cell Type Expression" name="marker">
            <el-col :span="16">
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

            <el-col :span="8">
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
              max-height="600"
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
              <span class="heatMapTable--colorbar--short"></span>
              <span>High logFC&gt;0</span>
            </div>
          </el-tab-pane>
        </el-tabs>
      </el-col>
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
      picloading: true,
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
      gloclu: "All",
      gloclures: [],
      selectgloclu: [],
      tabactiveName: "marker",
      data: [
        {
          label: "All",
          children: [
            {
              label: "Tcell",
              children: [
                {
                  label: "CD4",
                },
                {
                  label: "CD8",
                },
              ],
            },
            {
              label: "Bcell",
            },
            {
              label: "Myeloid",
            },
          ],
        },
      ],
      defaultProps: {
        children: "children",
        label: "label",
      },
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

  methods: {
    handleNodeClick(data) {
      this.getTableData1(data.label)
    },
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
    draw_chart(data, celltypeinfo, eleid) {
      // console.log(data)
      var targetdiv = document.getElementById(eleid);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);
      var xAxis = "UMAP_1";
      var yAxis = "UMAP_2";
      var xlabname = "";
      var plotdata = data.map((item) => [
        item["UMAP_1"],
        item["UMAP_2"],
        item["CellType"],
      ]);
      var COLOR_ALL = [
        "#cc4a5399",
        "#00ADDB99",
        "#7142AC99",
        "#42B54099",
        "#00008099",
        "#07702b99",
        "#7FFF0099",
        "#AD002A",
        "#ED000099",
        "#ABD20599",
        "#F0BE7E",
        "#4D221399",
        "#FDAF9199",
        "#85E1D099",
        "#C979CD99",
        "#F26A1299",
        "#ADB6B699",
        "#4B79AB99",
        "#0099B499",
        "#FF149399",
        "#00800099",
        "#1B191999",
      ];
      // console.log(celltypeinfo);
      var pieces = celltypeinfo.map(
        (item, index) =>
          (item = {
            celltype: item["CellType"],
            color: COLOR_ALL[index],
          })
      );
      // console.log(pieces);
      var typecolor = {};
      for (let i = 0; i < pieces.length; ++i) {
        typecolor[pieces[i].celltype] = pieces[i].color;
      }
      // console.log(typecolor);
      var celltype = celltypeinfo.map((item) => [item["CellType"]]);
      var CLUSTER_COUNT = pieces.length;
      var DIENSIION_CLUSTER_INDEX = 2;

      // var seriesList = [];
      // seriesList = pieces.map((item) => {
      //   var seriesObject = {};
      //   seriesObject.name = item[1];
      //   seriesObject.type = "scatter";
      //   seriesObject.itemStyle = { color: item[2] };
      //   seriesObject.emphasis = { focus: "series" };
      //   seriesObject.data = plotdata.filter(
      //     (data) => data[2] == seriesObject.name
      //   );
      //   return seriesObject;
      // });
      let option = {
        animation: false,
        visualMap: [
          {
            type: "piecewise",
            categories: celltypeinfo.map((item) => item["CellType"]),
            selectedMode: "single",
            // min: 0,
            // max: 5000,
            dimension: 2, // series.data 的第四个维度（即 value[3]）被映射
            // seriesIndex: 2, // 对第四个系列进行映射。
            inverse: true,
            align: "left",
            left: "",
            top: "center",
            inRange: {
              // 选中范围中的视觉配置
              // 定义了图形颜色映射的颜色列表
              color: COLOR_ALL,
              symbolSize: 10,
              colorAlpha: 70,
              // 数据最小值映射到'blue'上，
              // 最大值映射到'red'上，
              // 其余自动线性计算。
              // symbolSize: [30, 100], // 定义了图形尺寸的映射范围，
              // 数据最小值映射到30上，
              // 最大值映射到100上，
              // 其余自动线性计算。
            },
            outOfRange: {
              // 选中范围外的视觉配置
              color: COLOR_ALL,
              symbolSize: 2,
              colorAlpha: 10,
            },
          },
        ],
        // legend: {
        //   data: celltype,
        //   textStyle: {
        //     fontSize: 12,
        //     fontWeight: "bold",
        //   },
        //   orient: "vertical",
        //   x: "right", //可设定图例在左、右、居中
        //   y: "center", //可设定图例在上、下、居中
        //   padding: [100, 50, 0, 200], //可设定图例[距上方距离，距右方距离，距下方距离，距左方距离]
        // },
        grid: {
          left: "30%",
          right: "15%",
          bottom: "10%",
          top: "10%",
          containLabel: true,
        },
        xAxis: {
          name: xAxis,
          // show: false,
          position: "bottom",
          nameLocation: "center",
          nameGap: 25,
          offset: 0,
          nameTextStyle: {
            fontSize: 18,
            fontWeight: "bold",
          },
        },
        yAxis: {
          name: yAxis,
          position: "left",
          nameLocation: "center",
          nameGap: 25,
          nameTextStyle: {
            fontSize: 18,
            fontWeight: "bold",
          },
        },
        series: [
          {
            symbolSize: 10,
            data: plotdata,
            type: "scatter",
            // itemStyle: {
            //   color: function (val) {
            //     return typecolor[val.data[2]];
            //   },
            // },
            animation: false,
            silent: true,
            progressive: 0,
            // large: true,
            // largeThreshold: 20000,
          },
        ],
      };

      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
    sortChangeClick(column) {
      this.loadDir = "";
      this.sortCol = column.prop;
      this.sortOrder = column.order;
      this.loadpage = 1;
      this.tableData = [];
      this.getTableData2(this.loadpage, column.prop, column.order);
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
    //获取表格数据
    getTableData(page, sortCol, sortOrder) {
      this.getTableData1(this.gloclu);
      this.getTableData2(page, sortCol, sortOrder);
    },
    getTableData1(glocluster) {
      this.picloading = true;
      this.$http
        .get("/tiger/scumap.php", {
          params: {
            datasetid: this.cancer,
            type: glocluster,
          },
        })
        .then((res) => {
          // this.tableData = res.data.list;
          // console.log(this.selectgloclu)
          this.draw_chart(res.data.list, res.data.total, "scumap_celltype");
          this.draw_chart(res.data.list, res.data.total, "scumap_celltype2");
          this.picloading = false;
        })
        .catch((error) => {
          console.log(error);
        });
    },
    getTableData2(page, sortCol, sortOrder) {
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
      this.getTableData2(this.loadpage, "", "");
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
      this.getTableData2(1, "", "");
    },
  },
  components: {
    "v-celltypedetail": () => import("./celltypedetail.vue"),
    "v-scpathway": () => import("./scpathway.vue"),
  },
  watch: {
    clickGene() {
      // console.log("click");
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
  font-size: 20px;
  height: 55px;
  padding: 10px;
  font-weight: bold !important;
}
</style>
