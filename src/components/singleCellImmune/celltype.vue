<template>
  <div>
    <el-row type="flex" justify="space-around">
      <el-col :span="4">
        <el-tree
          :data="treedata"
          default-expand-all
          :highlight-current="true"
          :expand-on-click-node="false"
          :props="defaultProps"
          @node-click="handleNodeClick"
        ></el-tree
      ></el-col>
      <el-col :span="10" v-loading="picloading">
        <el-row>
          <div id="scumap_celltype" style="width: 600px; height: 400px"></div>
        </el-row>
        <el-row>
          <el-tabs v-model="tabactivePlotName" @tab-click="handleClickplot">
            <el-radio-group v-model="radio">
              <el-radio
                v-for="item in propgroup"
                :key="item.key"
                :label="item.key"
                @change="handlegenechange"
                >{{ item.name }}</el-radio
              >
            </el-radio-group>
            <el-tab-pane label="Expression UMAP" name="expumap">
              <div
                id="scumap_celltype2"
                style="width: 600px; height: 400px"
              ></div>
            </el-tab-pane>
            <el-tab-pane label="Box Plot" name="expbox">
              <div id="scboxplot" style="width: 600px; height: 400px"></div>
            </el-tab-pane>
            <el-tab-pane label="Mountain" name="expmoun">
              <div id="scmountain" style="width: 600px; height: 400px"></div>
            </el-tab-pane>
          </el-tabs>
        </el-row>
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
      gloclu: "Tcell",
      gloclures: [],
      selectgloclu: [],
      tabactiveName: "marker",
      tabactivePlotName: "expumap",
      radio: "nCount_RNA",
      propgroup: [
        { key: "nCount_RNA", name: "UMI" },
        { key: "nFeature_RNA", name: "Mito" },
      ],
      umapchart: "",
      umapdata: [],
      expumapchart: "",
      exphashtable: {},
      treedata: [
        {
          label: "All",
          children: [
            {
              label: "Tcell",
              children: [
                {
                  label: "CD4",
                  children: [
                    {
                      label: "CD4_C2_KLRB1",
                    },
                    {
                      label: "CD4_C6_GIMAP1",
                    },
                    {
                      label: "CD4_C3_GAPDH",
                    },
                    {
                      label: "CD4_C5_RPS4Y1",
                    },
                    {
                      label: "CD4_C1_RPS4Y1",
                    },
                    {
                      label: "CD4_C4_OLFM4",
                    },
                    {
                      label: "CD4_C7_INS",
                    },
                  ],
                },
                {
                  label: "CD8",
                  children: [
                    {
                      label: "CD8_C2_CCL5",
                    },
                    {
                      label: "CD8_C4_SELL",
                    },
                    {
                      label: "CD8_C1_RPS4Y1",
                    },
                    {
                      label: "CD8_C5_INS",
                    },
                    {
                      label: "CD8_C6_GNLY",
                    },
                    {
                      label: "CD8_C3_MT2A",
                    },
                    {
                      label: "CD8_C8_CXCL13",
                    },
                    {
                      label: "CD8_C7_KLRB1",
                    },
                  ],
                },
              ],
            },
            {
              label: "Bcell",
              children: [
                {
                  label: "B_C4_IGLL5",
                },
                {
                  label: "B_C6_INS",
                },
                {
                  label: "B_C3_STMN1",
                },
                {
                  label: "B_C2_RP5-887A10.1",
                },
                {
                  label: "B_C1_RPS4Y1",
                },
                {
                  label: "B_C5_TCL1A",
                },
              ],
            },
            {
              label: "Myeloid",
              children: [
                {
                  label: "Mye_C2_HLA-DPB1",
                },
                {
                  label: "Mye_C1_SPP1",
                },
                {
                  label: "Mye_C6_APOE",
                },
                {
                  label: "Mye_C4_PRSS1",
                },
                {
                  label: "Mye_C3_APOE",
                },
                {
                  label: "Mye_C5_FCER1A",
                },
                {
                  label: "Mye_C7_S100A8",
                },
                {
                  label: "Mye_C8_BIRC3",
                },
                {
                  label: "Mye_C9_GZMB",
                },
              ],
            },
            {
              label: "Malignant",
            },
            {
              label: "Stellate",
            },
            {
              label: "Fibroblast",
            },
            {
              label: "Ductal",
            },
            {
              label: "Plasma",
            },
            {
              label: "Endothelial",
            },
            {
              label: "Endocrine",
            },
            {
              label: "Acinar",
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
    }
    Vue.set(this.selectgloclu, 0, this.gloclu);
    this.getTableData(1, "", "");
  },

  methods: {
    toTree(data) {
      // 删除 所有 children,以防止多次调用
      data.forEach(function (item) {
        delete item.children;
      });

      // 将数据存储为 以 id 为 KEY 的 map 索引数据列
      var map = {};
      data.forEach(function (item) {
        map[item.id] = item;
      });
      //        console.log(map);
      var val = [];
      data.forEach(function (item) {
        // 以当前遍历项，的pid,去map对象中找到索引的id
        var parent = map[item.pid];
        // 好绕啊，如果找到索引，那么说明此项不在顶级当中,那么需要把此项添加到，他对应的父级中
        if (parent) {
          (parent.children || (parent.children = [])).push(item);
        } else {
          //如果没有在map中找到对应的索引ID,那么直接把 当前的item添加到 val结果集中，作为顶级
          val.push(item);
        }
      });
      return val;
    },
    handleNodeClick(item, e) {
      // console.log(e.parent.childNodes)
      // var test = e.parent.childNodes.forEach(function (item) {
      //   item.data.label
      // });
      // console.log(test)
      var viewtype = "";
      // leaf name
      var seltype = {};
      seltype[item.label] = true;
      // parent name
      // console.log(e.parent.data.label)
      if (e.parent.data.label == undefined) {
        viewtype = "All";
      } else {
        viewtype = e.parent.data.label;
      }
      this.gloclu = viewtype;
      if (this.selectgloclu[0] == viewtype) {
        this.umapchart.dispatchAction({
          type: "selectDataRange",
          // 选取 20 到 40 的值范围

          selected: seltype,
          // 取消选中第二段
        });
      } else {
        this.getTableData1(viewtype);
        Vue.set(this.selectgloclu, 0, viewtype);
        this.reset();
        this.getTableData2(this.loadpage, this.sortCol, this.sortOrder);
      }
    },
    handlegenechange(gene) {
      // console.log(gene);

      if (this.umapdata[0].hasOwnProperty(gene)) {
        this.expumapchart.setOption({
          // visualMap: {
          //   min: -10,
          //   max: 10,
          //   seriesIndex: 2,
          //   dimension: 0,
          // },
          series: {
            data: this.umapdata.map((item) => [
              item["UMAP_1"],
              item["UMAP_2"],
              item[gene],
            ]),
          },
        });
      } else {
        console.log("error");
        this.getGeneExp(this.gloclu, gene);
      }
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
      this.umapchart = window.echarts.init(targetdiv);
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
            show: false,
            type: "piecewise",
            categories: celltypeinfo.map((item) => item["CellType"]),
            selectedMode: "single",
            // min: 0,
            // max: 5000,
            dimension: 2, // series.data 的第四个维度（即 value[3]）被映射
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
              symbolSize: 1,
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
          left: "10%",
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
            sampling: "average",
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

      this.umapchart.clear();
      this.umapchart.setOption(option);
      window.onresize = function () {
        this.umapchart.resize();
      };
    },
    draw_chart_expumap(data, selected_prop, eleid) {
      // console.log(data);
      var targetdiv = document.getElementById(eleid);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      this.expumapchart = window.echarts.init(targetdiv);
      var xAxis = "UMAP_1";
      var yAxis = "UMAP_2";
      // var plotdata = data.map((item) => [
      //   item["UMAP_1"],
      //   item["UMAP_2"],
      //   { nCount_RNA: item["nCount_RNA"], nFeature_RNA: item["nFeature_RNA"] },
      // ]);
      var plotdata = data.map((item) => [
        item["UMAP_1"],
        item["UMAP_2"],
        item[selected_prop],
      ]);
      // console.log(celltypeinfo);
      // console.log(pieces);

      let option = {
        animation: false,
        visualMap: {
          min: 1,
          max: 4000,
          dimension: 2,
          orient: "vertical",
          right: 30,
          top: "center",
          text: ["HIGH", "LOW"],
          // calculable: true,
          inRange: {
            color: ["#00ADDB", "#EEE", "#cc4a53"],
          },
        },
        grid: {
          left: "10%",
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
            symbolSize: 5,
            data: plotdata,
            type: "scatter",
            animation: false,
            silent: true,
            progressive: 0,
          },
        ],
      };

      this.expumapchart.clear();
      this.expumapchart.setOption(option);
      window.onresize = function () {
        this.expumapchart.resize();
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
    // getTreeType( drawdata ){
    //   drawdata.forEach(function (item) {
    //     delete item.GlobalCluster;
    //   });
    // },
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
          // console.log(res.data.list)
          this.umapdata = res.data.list;
          var TOTAL_NUM = this.umapdata.length;
          if (TOTAL_NUM > 8000) {
            //要取得的个数，表示我们要从原数组中随机取3个元素
            var COUNT = 8000,
            //保存结果的数组
            result = [];
            // console.log("原数组:", this.umapdata );
            //此段代码由Fisher-Yates shuflle算法更改而来
            var m = this.umapdata.length,
              t,
              i;
            while (m && result.length < COUNT) {
              // 随机选取一个元素…
              i = Math.floor(Math.random() * m--);
              t = this.umapdata[m];
              this.umapdata[m] = this.umapdata[i];
              this.umapdata[i] = t;
              result.push(this.umapdata[m]);
            }
            // console.log("结果数组:", result);
            this.umapdata = result;
          }

          this.draw_chart(this.umapdata, res.data.total, "scumap_celltype");
          // this.getTreeType(res.data.list);
          this.draw_chart_expumap(
            this.umapdata,
            this.radio,
            "scumap_celltype2"
          );
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
    getGeneExp(glocluster, gene) {
      // console.log(this.umapdata);
      this.$http
        .get("/tiger/scgene.php", {
          params: {
            datasetid: this.cancer,
            type: glocluster,
            gene: gene,
          },
        })
        .then((res) => {
          // this.tableData = res.data.list;
          console.log(res.data.list);
          // for()
          // this.exphashtable = res.data.list.forEach(function(item){
          //   var
          // });
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
        this.propgroup.push({ key: this.clickGene, name: this.clickGene });
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
    handleClickplot(tab) {
      this.tabactivePlotName = tab.name;
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
