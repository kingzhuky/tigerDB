<template>
  <div>
    <el-row>
      <div id="scumap_celltype" style="width: 1000px; height: 600px"></div>
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
    draw_chart(data, celltypeinfo) {
      // console.log(data)
      var targetdiv = document.getElementById("scumap_celltype");
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
      console.log(celltypeinfo);
      var pieces = celltypeinfo.map((item, index) => [
        index,
        item["CellType"],
        COLOR_ALL[index],
      ]);
      var celltype = celltypeinfo.map((item) => [
        item["CellType"],
      ]);
      var CLUSTER_COUNT = pieces.length;
      var DIENSIION_CLUSTER_INDEX = 2;

      var seriesList = [];
      seriesList = pieces.map((item) => {
        var seriesObject = {};
        seriesObject.name = item[1];
        seriesObject.type = "scatter";
        seriesObject.itemStyle = { color: item[2] };
        seriesObject.emphasis = { focus: "series" };
        seriesObject.data = plotdata.filter(
          (data) => data[2] == seriesObject.name
        );
        return seriesObject;
      });

      let option = {
        animation: false,
        legend: {
          data: celltype,
          textStyle: {
            fontSize: 12,
            fontWeight: "bold",
          },
          orient: "vertical",
          x: "right", //可设定图例在左、右、居中
          y: "center", //可设定图例在上、下、居中
          padding: [0, 50, 0, 200], //可设定图例[距上方距离，距右方距离，距下方距离，距左方距离]
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
        // tooltip: {
        //   formatter: function (params) {
        //     return (
        //       "Gene: " +
        //       params.data[2] +
        //       "<br />P: " +
        //       params.data[1] +
        //       "<br />" +
        //       xlabname +
        //       params.data[0]
        //     );
        //   },
        // },
        series: seriesList,
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
    //获取表格数据
    getTableData(page, sortCol, sortOrder) {
      this.loading = true;
      this.$http
        .get("/tiger/scumap.php", {
          params: {
            datasetid: this.cancer,
            type: "All",
          },
        })
        .then((res) => {
          this.tableData = res.data.list;
          // console.log(this.selectgloclu)
          this.draw_chart(this.tableData, res.data.total);
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
