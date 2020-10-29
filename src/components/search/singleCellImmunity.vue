<template>
  <div>
    <div class="textitem">
      <el-card>
        <p class="card-title">Expression in different cell types</p>
        <el-row>
          <el-col :span="16" v-loading="loading">
            <div id="scaterid" style="width: 600px;height:400px;"></div>
          </el-col>
          <el-col :span="4" :offset="1">
            <br />
            <br />
            <br />
            <el-row>
              <el-select v-model="cancer" @change="cancerSelectChange" placeholder="Cancer">
                <el-option
                  v-for="item in canceroptions"
                  :key="item.cancer"
                  :label="item.cancer"
                  :value="item.cancer"
                ></el-option>
              </el-select>
            </el-row>
            <br />
            <br />
            <el-row>
              <el-select v-model="gloClu" @change="gloCluChange">
                <el-option
                  v-for="item in gloCluoptions"
                  :key="item.GlobalCluster"
                  :label="item.GlobalCluster"
                  :value="item.GlobalCluster"
                ></el-option>
              </el-select>
            </el-row>
            <br />
            <br />
            <el-row class="plot">
              <el-button id="anabt" @click="clickPlot()" style="width:210px">Plot</el-button>
            </el-row>
          </el-col>
        </el-row>

        <div class="textitem" v-if="geneshow" v-loading="geneloading">
          <p class="card-title">Gene Expression in cell type selected</p>
          <div class="geneExp">
            <img id="singleimg" :src="imgUrlBox" />

            <img id="singleimg" :src="imgUrlBar" />
          </div>
        </div>
      </el-card>
    </div>

    <div class="textitem">
      <el-card>
        <p
          class="card-title"
        >Top 10 genes correlated with {{this.seargene}} in each cell type selected</p>
        <div>
          <el-row class="selectrow">
            <el-col :span="8">
              <span class="demonstration">DataSet:</span>
              <el-select
                v-model="CancerType"
                @change="CancerTypeSelectChange"
                placeholder="DataSet"
              >
                <el-option-group
                  v-for="group in canceroptionsTable"
                  :key="group.label"
                  :label="group.label"
                >
                  <el-option
                    v-for="item in group.options"
                    :key="item.value"
                    :label="item.value"
                    :value="item.value"
                  ></el-option>
                </el-option-group>
              </el-select>
            </el-col>

            <el-col :span="8">
              <span class="demonstration">Global Cluster:</span>
              <el-select v-model="GlobalCluster" @change="GlobalClusterChange">
                <el-option
                  v-for="item in gloCluoptions"
                  :key="item.GlobalCluster"
                  :label="item.GlobalCluster"
                  :value="item.GlobalCluster"
                ></el-option>
              </el-select>
            </el-col>

            <el-col :span="8">
              <span class="demonstration">Cell Type:</span>
              <el-select v-model="CellType" v-loading="CellTypeLoading" @change="subClusterChange">
                <el-option
                  v-for="item in CellTypeCluoptions"
                  :key="item.CellType"
                  :label="item.CellType"
                  :value="item.CellType"
                ></el-option>
              </el-select>
            </el-col>
          </el-row>
          <br />
          <v-singleCellImmunityCorTable
            ref="singleCellImmunityCorTableRef"
            :seargene="seargene"
            :CancerType="CancerType"
            :GlobalCluster="GlobalCluster"
            :CellType="CellType"
          ></v-singleCellImmunityCorTable>
        </div>
      </el-card>
    </div>

    <el-card>
      <div class="textitem" v-show="singleCellImmuTumorshow" v-loading="singleCellImmuTumorloading">
        <p class="card-title">Differential expression between tumor and normal per cell type</p>
        <div class="geneExp">
          <div id="singleCellImmuTumor" class="scaterPlot" style="width: 800px;height:400px;"></div>
          <div v-show="singleCellImmuTumorImgshow" v-loading="singleCellImmuTumorImgloading">
            <!-- <img id="singleimg" :src="imgpathBar2" /> -->
            <img
                id="singleimg"
                fit="fill"
                height="350px"
                style="position:relative;top:40px;"
                :src="imgpathBar2" 
                @click="previewImg(imgpathBar2)"/>
          </div>
        </div>

        <el-table :data="DiffExpTumorTableData" max-height="800" style="width: 100%">
          <el-table-column label="CancerType" prop="CancerType" sortable></el-table-column>
          <el-table-column prop="GlobalCluster" label="GlobalCluster" sortable></el-table-column>
          <el-table-column prop="CellType" label="CellType" sortable></el-table-column>
          <el-table-column prop="Log2FoldChange" label="Log2FoldChange" sortable></el-table-column>
          <el-table-column prop="P_Value" label="P-Value" sortable></el-table-column>
        </el-table>
      </div>

      <div
        class="textitem"
        v-show="singleCellImmuResponseshow"
        v-loading="singleCellImmuResponseloading"
      >
        <p
          class="card-title"
        >Differential expression between response and non-response per cell type</p>
        <div class="geneExp">
          <div id="singleCellImmuResponse" class="scaterPlot" style="width: 800px;height:400px;"></div>
          <div v-show="singleCellImmuResponseImgshow" v-loading="singleCellImmuResponseImgloading">
            <img
                id="singleimg"
                fit="fill"
                height="350px"
                style="position:relative;top:40px;"
                :src="imgpathBar3" 
                @click="previewImg(imgpathBar3)"/>
          </div>
        </div>
        <el-table :data="DiffExpResponseableData" max-height="800" style="width: 100%">
          <el-table-column label="CancerType" prop="CancerType" sortable></el-table-column>
          <el-table-column prop="GlobalCluster" label="GlobalCluster" sortable></el-table-column>
          <el-table-column prop="CellType" label="CellType" sortable></el-table-column>
          <el-table-column prop="Log2FoldChange" label="Log2FoldChange" sortable></el-table-column>
          <el-table-column prop="P_Value" label="P-Value" sortable></el-table-column>
        </el-table>
      </div>
    </el-card>
  </div>
</template>

<script>
import singleCellImmunityCorTable from "./singleCellImmunityCorTable.vue";

export default {
  props: {
    seargene: String,
  },
  data() {
    return {
      expands: [],
      detailimgShow: true,
      currentPage: 1,
      pageSize: 20,
      total: 200,
      CellTypeLoading: false,
      GlobalCluster: "All",
      CellType: "CAF",
      CancerType: "BCC",
      singleCellImmuTumorImgshow: false,
      singleCellImmuTumorImgloading: false,
      singleCellImmuResponseImgshow: false,
      singleCellImmuResponseImgloading: false,
      singleCellImmuTumorshow: false,
      singleCellImmuTumorloading: false,
      singleCellImmuResponseshow: false,
      singleCellImmuResponseloading: false,
      singleCellCorloading: false,
      loading: false,
      gloCluoptions: [],
      gloClu: "All",
      cancer: "BCC",
      canceroptions: [],
      canceroptionsTable: [],
      subClu: [],
      geneplots: [],
      ReactomeTableData: [],
      geneshow: false,
      imgpathBox: "",
      imgpathBar: "",
      imgpathBar1: "",
      imgpathBar2: "",
      oldseargene: "",
      imgpathBar3: "",
      picScattername: "",
      picScatterloading: true,
      DiffExpTumorTableData: []
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
      this.getTableData(this.seargene);
      this.searchTable();
      this.getScaData(
        this.seargene,
        "home_scdiffexp_tn",
        "singleCellImmuTumor"
      );
      this.getScaData(
        this.seargene,
        "home_scdiffexp_rnr",
        "singleCellImmuResponse"
      );

      this.getcancer();
      this.getgloClu();
      this.getCellType();
    });
  },
  components: {
    "v-singleCellImmunityCorTable": singleCellImmunityCorTable,
  },

  computed: {
    imgUrlBox: function () {
      return this.imgpathBox;
    },
    imgUrlBar: function () {
      return this.imgpathBar;
    },
  },

  methods: {
    reset() {
      this.DiffExpTumorTableData = [];
      this.DiffExpTumorTableData = [];
      this.imgpathBox = "";
      this.imgpathBar = "";
    },

    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.reset();
        this.$refs.singleCellImmunityCorTableRef.reset();
        this.oldseargene = this.seargene;
        this.getTableData(this.seargene);

        this.getScaData(
          this.seargene,
          "home_scdiffexp_tn",
          "singleCellImmuTumor"
        );
        this.getScaData(
          this.seargene,
          "home_scdiffexp_rnr",
          "singleCellImmuResponse"
        );
      }
    },

    getcancer() {
      this.$http.get("/tiger/singlecelldataset.json").then((res) => {
        this.canceroptionsTable = res.data;
      });
    },
    cancerSelectChange() {
      this.getgloClu();
    },

    CancerTypeSelectChange() {
      this.getgloClu();
      this.getCellType();
    },
    GlobalClusterChange() {
      this.getCellType();
    },
    subClusterChange() {
      this.searchTable();
    },
    getgloClu() {
      this.$http
        .get("/tiger/scglocluster.php", {
          params: {
            cancer: this.cancer,
            type: "homescinfo",
          },
        })
        .then((res) => {
          this.gloCluoptions = res.data.list;
          this.GlobalCluster = res.data.list[0].GlobalCluster;
          this.gloClu = res.data.list[0].GlobalCluster;
          this.getcrossClu();
        });
    },
    getCellType() {
      this.CellTypeLoading = true;
      this.$http
        .get("/tiger/scCelltype.php", {
          params: {
            CancerType: this.CancerType,
            GlobalCluster: this.GlobalCluster,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.CellTypeLoading = false;
            this.CellTypeCluoptions = res.data.list;
            this.CellType = res.data.list[0].CellType;
            this.searchTable();
          }
        });
    },
    searchTable() {
      this.$refs.singleCellImmunityCorTableRef.getDiagramData(
        this.seargene,
        "singleCellCorTumor",
        1,
        10
      );
    },

    getcrossClu() {
      this.$http
        .get("/tiger/sccluster.php", {
          params: {
            cancer: this.cancer,
            gloclu: this.gloClu,
            type: "singlecellcluster",
          },
        })
        .then((res) => {
          //this.subClucoptions = res.data.list;
          this.subClu = res.data.list;
        });
    },

    draw_chart(cancer, data) {
      var targetdiv = document.getElementById("scaterid");
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);
      var hours = cancer;
      var days = [0, 1, 2, 3, 4, 5];
      var option2 = {
        title: {
          text: "Cell Type Marker ( |Log2FC| )",
          link: "https://github.com/pissang/echarts-next/graphs/punch-card",
        },
        legend: {
          data: ["Punch Card"],
          left: "right",
        },
        polar: {},
        angleAxis: {
          type: "category",
          data: hours,
          boundaryGap: false,
          splitLine: {
            show: true,
            lineStyle: {
              color: "#999",
              type: "dashed",
            },
          },
          axisLine: {
            show: true,
          },
        },
        radiusAxis: {
          type: "value",
          data: days,
          axisLine: {
            show: false,
          },
          axisLabel: {
            rotate: 45,
          },
        },
        series: [
          {
            name: "Cell Type Marker",
            type: "scatter",
            coordinateSystem: "polar",
            symbolSize: 20,
            emphasis: {
              label: {
                borderWidth: 1.5,
                show: true,
                position: "right",
                distance: 10,
                color: "rgba(255, 255, 255, 1)",
                fontStyle: "normal",
                fontWeight: "bold",
                fontFamily: "Arial",
                fontSize: 15,
                align: "left",
                verticalAlign: "middle",
                backgroundColor: "rgba(50, 50, 50, 0.8)",
                borderColor: "rgba(0, 0, 0, 1)",
                padding: [9, 9, 9, 9],
                borderRadius: [5, 5, 5, 5],
                lineHeight: 25,
                formatter:
                  "CancerType: {@[1]}\nCellType: {@[2]}\nLog2FC: {@[3]}",
              },
            },
            data: data,
          },
        ],
      };
      myChart_mercor.clear();
      myChart_mercor.setOption(option2);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
    //获取表格数据
    getTableData(gene) {
      this.loading = true;
      this.$http
        .get("/tiger/home.php", {
          params: {
            gene: gene,
            //type: "home"
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            console.log(Object.values(res.data.cancer))
            console.log("data.list:")
            console.log(res.data.list)
            console.log("data.table:")
            console.log(res.data.tabledata)
            this.draw_chart(Object.values(res.data.cancer), res.data.list);
            this.loading = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    getScaData(gene, conditi, id) {
      if (id === "singleCellImmuTumor") {
        this.singleCellImmuTumorshow = true;
        this.singleCellImmuTumorImgshow = false;
        this.imgpathBar2 = "";
        this.singleCellImmuTumorloading = true;
      } else {
        this.singleCellImmuResponseshow = true;
        this.singleCellImmuResponseImgshow = false;
        this.singleCellImmuResponseloading = true;
        this.imgpathBar3 = "";
      }

      this.$http
        .get("/tiger/homeresponse.php", {
          params: {
            gene: gene,
            conditi: conditi,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            if (res.data.list.length === 0) {
              if (id === "singleCellImmuTumor") {
                this.singleCellImmuTumorshow = false;
              } else {
                this.singleCellImmuResponseshow = false;
              }
            } else {
              this.draw_chart_sca(res.data.list, id);
              if (id === "singleCellImmuTumor") {
                this.singleCellImmuTumorloading = false;
                this.DiffExpTumorTableData = res.data.infosTable;
              } else {
                this.DiffExpResponseableData = res.data.infosTable;
                this.singleCellImmuResponseloading = false;
              }
            }
          } else {
            if (id === "singleCellImmuTumor") {
              this.singleCellImmuTumorshow = false;
            } else {
              this.singleCellImmuResponseshow = false;
            }
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    differentialExpressionPlot(cancer, gloclu, subClu, id) {
      var that = this;

      if (id === "singleCellImmuTumor") {
        that.singleCellImmuTumorImgloading = true;
        that.singleCellImmuTumorImgshow = true;
      } else {
        that.singleCellImmuResponseImgshow = true;
        that.singleCellImmuResponseImgloading = true;
      }

      this.$http
        .get("/tiger/scimmudiffexpdetailgene.php", {
          params: {
            cancer: cancer,
            gene: this.seargene,
            gloclu: gloclu,
            subclu: subClu,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            if (res.data.output[0] === "0") {
              if (id === "singleCellImmuTumor") {
                that.singleCellImmuTumorImgshow = false;
              } else {
                that.singleCellImmuResponseImgshow = false;
              }
            } else {
              if (id === "singleCellImmuTumor") {
                that.singleCellImmuTumorImgshow = true;
                that.singleCellImmuTumorImgloading = false;
                that.imgpathBar2 =
                  "/tiger/img/" + res.data.output[0].split(",")[0];
              } else {
                that.singleCellImmuResponseImgshow = true;
                that.singleCellImmuResponseImgloading = false;
                that.imgpathBar3 =
                  "/tiger/img/" + res.data.output[0].split(",")[0];
              }
            }
          } else {
            if (id === "singleCellImmuTumor") {
              that.singleCellImmuTumorImgshow = false;
            } else {
              that.singleCellImmuResponseImgshow = false;
            }
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    // draw_chart_Diagram(data, id) {
    //   var targetdiv = document.getElementById(id);
    //   //let myChart_mercor = this.$echarts.init(targetdiv);
    //   //cdn替换为
    //   let myChart_mercor = window.echarts.init(targetdiv);

    //   let option = {
    //     title: {
    //       text: "Sankey Diagram",
    //     },
    //     tooltip: {
    //       trigger: "item",
    //       triggerOn: "mousemove",
    //     },

    //     series: [
    //       {
    //         type: "sankey",
    //         data: data.nodes,
    //         links: data.links,
    //         focusNodeAdjacency: true,
    //         levels: [
    //           {
    //             depth: 0,
    //             itemStyle: {
    //               color: "#fbb4ae",
    //             },
    //             lineStyle: {
    //               color: "source",
    //               opacity: 0.6,
    //             },
    //           },
    //           {
    //             depth: 1,
    //             itemStyle: {
    //               color: "#b3cde3",
    //             },
    //             lineStyle: {
    //               color: "source",
    //               opacity: 0.6,
    //             },
    //           },
    //           {
    //             depth: 2,
    //             itemStyle: {
    //               color: "#ccebc5",
    //             },
    //             lineStyle: {
    //               color: "source",
    //               opacity: 0.6,
    //             },
    //           },
    //         ],
    //         lineStyle: {
    //           curveness: 0.5,
    //         },
    //       },
    //     ],
    //   };

    //   myChart_mercor.clear();
    //   myChart_mercor.setOption(option);
    //   window.onresize = function () {
    //     myChart_mercor.resize();
    //   };
    // },

    draw_chart_sca(data, id) {
      var that = this;
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);

      let option = {
        xAxis: { name: "Log2FC" },
        yAxis: {
          name: "–log10(P-Value)",
          axisLine: { show: false },
          axisTick: { show: false },
        },
        tooltip: {
          formatter: "{c}",
        },
        series: [
          {
            symbolSize: 20,
            data: data,
            type: "scatter",
          },
        ],
      };

      myChart_mercor.clear();
      myChart_mercor.setOption(option);

      myChart_mercor.on("click", function (param) {
        if (param.componentSubType === "scatter") {
          //console.log(param.data);
          that.differentialExpressionPlot(
            param.data[2],
            param.data[3],
            param.data[4],
            id
          );
        }
      });

      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
    previewImg(url){
    this.$hevueImgPreview({
      url: url,
      multiple: false, // 开启多图预览模式
      keyboard: true,
      nowImgIndex: 0, // 多图预览，默认展示第二张图片
      mainBackground: 'rgba(0, 0, 0, .5)', // 整体背景颜色
    })
    },
  },
};
</script>


<style>
div#scaterid {
  margin: 0 auto;
}
.scPagination.el-pagination.is-background {
  text-align: center;
}
.geneExp {
  display: flex;
  justify-content: center;
}
.detailimg {
  text-align: center;
}
</style>
