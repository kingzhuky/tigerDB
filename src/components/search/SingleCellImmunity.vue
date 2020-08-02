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
                  :key="item.glo"
                  :label="item.glo"
                  :value="item.glo"
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
      </el-card>
    </div>

    <div class="textitem">
      <el-card v-if="geneshow" v-loading="geneloading">
        <p class="card-title">Gene Expression in cell type selected</p>
        <div class="geneExp">
          <img id="singleimg" width="550px" :src="imgUrlBox" />

          <img id="singleimg" width="550px" :src="imgUrlBar" />
        </div>
      </el-card>
    </div>

    <div class="textitem">
      <el-card v-if="singleCellCorShow" v-loading="singleCellCorloading">
        <p
          class="card-title"
        >Top 10 genes correlated with {{this.seargene}} in each cell type selected</p>
        <div class="geneExp">
          <div id="singleCellCorTumor" class="scaterPlot" style="width: 1200px;height:1000px;"></div>
        </div>
      </el-card>
    </div>

    <div class="textitem">
      <el-card v-if="singleCellImmuTumorshow" v-loading="singleCellImmuTumorloading">
        <p class="card-title">Differential expression between tumor and normal per cell type</p>
        <div class="geneExp">
          <div id="singleCellImmuTumor" class="scaterPlot" style="width: 600px;height:400px;"></div>
          <img id="singleimg" width="550px" :src="imgUrlBar2" />
        </div>
      </el-card>
    </div>

    <div class="textitem">
      <el-card v-if="singleCellImmuResponseshow" v-loading="singleCellImmuResponseloading">
        <p
          class="card-title"
        >Differential expression between response and non-response per cell type</p>
        <div class="geneExp">
          <div id="singleCellImmuResponse" class="scaterPlot" style="width: 600px;height:400px;"></div>
          <img id="singleimg" width="550px" :src="imgUrlBar3" />
        </div>
      </el-card>
    </div>

    <!-- <el-table :data="tableData" max-height="600" style="width: 100%">
      <el-table-column prop="GENE_SYMBOL" align="center" border label="GENE SYMBOL"></el-table-column>
      <el-table-column prop="CellType" align="center" border label="Dataset"></el-table-column>
      <el-table-column prop="CancerType" align="center" border label="Cancer Type"></el-table-column>
      <el-table-column prop="Log2FoldChange" align="center" border label="Log2FC"></el-table-column>
      <el-table-column prop="P_Value" align="center" border label="P-Value"></el-table-column>
    </el-table>-->
  </div>
</template>

<script>
import echarts from "echarts";
export default {
  props: {
    seargene: String,
  },
  data() {
    return {
      //tableData: [],
      singleCellImmuTumorshow: true,
      singleCellImmuTumorloading: false,
      singleCellImmuResponseshow: true,
      singleCellImmuResponseloading: false,
      singleCellCorShow: true,
      singleCellCorloading: false,
      loading: false,
      gloCluoptions: [],
      gloclu: "All",
      cancer: "BCC",
      canceroptions: [],
      subClu: [],
      geneplots: [],
      geneshow: false,
      imgpathBox: "",
      imgpathBar: "",
      imgpathBar1: "",
      imgpathBar2: "",
      oldseargene: "",
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
      this.getTableData(this.seargene);
      this.getcancer();
      this.getgloClu();
      this.getScaData(this.seargene, "Responder", "singleCellImmuTumor");
      this.getScaData(this.seargene, "Responder", "singleCellImmuResponse");
      this.getDiagramData(this.seargene, "singleCellCorTumor");
    });
  },

  computed: {
    imgUrlBox: function () {
      return this.imgpathBox;
    },
    imgUrlBar: function () {
      return this.imgpathBar;
    },
    imgUrlBar2: function () {
      return this.imgpathBar2;
    },
    imgUrlBar3: function () {
      return this.imgpathBar3;
    },
  },

  methods: {
    Plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        this.clickPlot(this.seargene);
      }
    },
    clickPlot() {
      this.genePlot(this.seargene);
      this.getScaData(this.seargene, "Responder", "singleCellImmuTumor");
      this.getScaData(this.seargene, "Responder", "singleCellImmuResponse");
      this.getDiagramData(this.seargene, "singleCellCorTumor");
    },
    genePlot(clickgene) {
      var that = this;
      that.geneloading = true;
      that.geneshow = true;
      this.$http
        .get("/tiger/scimmudiffexpdetailgene.php", {
          params: {
            cancer: this.cancer,
            gene: clickgene,
            gloclu: this.gloclu,
            subclu: this.subClu.join(","),
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            if (res.data.output[0] === "0") {
              that.geneshow = false;
            } else {
              that.imgpathBox = "tiger/img/" + res.data.output[0].split(",")[0];
              that.imgpathBar = "tiger/img/" + res.data.output[0].split(",")[1];
              that.imgpathBar2 =
                "tiger/img/" + res.data.output[0].split(",")[2];
              //that.imgpathBar3='tiger/img/'+res.data.output[0].split(',')[3]
              that.geneshow = true;
            }
            //that.geneplots = res.data.output[0];
            that.geneloading = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },

    getcancer() {
      this.$http.get("/tiger/sccancer.php").then((res) => {
        this.canceroptions = res.data.list;
      });
    },
    cancerSelectChange() {
      this.getgloClu();
    },

    getgloClu() {
      this.$http
        .get("/tiger/scglocluster.php", {
          params: {
            cancer: this.cancer,
            type: "singlecellcluster",
          },
        })
        .then((res) => {
          this.gloCluoptions = res.data.list;
          this.gloClu = res.data.list[0].glo;
          this.getcrossClu();
        });
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
      var days = [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5];
      var data = data;
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
            show: false,
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
            this.draw_chart(Object.values(res.data.cancer), res.data.list);
            this.loading = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    getScaData(gene, conditi, id) {
      this.cardLoading = true;
      this.$http
        .get("/tiger/homeresponse.php", {
          params: {
            gene: gene,
            conditi: conditi,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.draw_chart_sca(res.data.list, id);
            //this.diffExpRespontableData = res.data.datatable;
            this.singleCellImmuTumorshow = true;
            this.singleCellImmuResponseshow = true;
            this.cardLoading = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    getDiagramData(gene, id) {
      this.singleCellCorloading = true;
      this.$http
        .get("/tiger/searchcoea.php", {
          params: {
            gene: gene,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.draw_chart_Diagram(res.data, id);
            this.singleCellCorShow = true;
            this.singleCellCorloading = false;
          } else {
            this.singleCellCorShow = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },

    draw_chart_Diagram(data, id) {
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);

      let option = {
        title: {
          text: "Sankey Diagram",
        },
        tooltip: {
          trigger: "item",
          triggerOn: "mousemove",
        },
        
        series: [
          {
            type: "sankey",
            data: data.nodes,
            links: data.links,
            focusNodeAdjacency: true,
            levels: [
              {
                depth: 0,
                itemStyle: {
                  color: "#fbb4ae",
                },
                lineStyle: {
                  color: "source",
                  opacity: 0.6,
                },
              },
              {
                depth: 1,
                itemStyle: {
                  color: "#b3cde3",
                },
                lineStyle: {
                  color: "source",
                  opacity: 0.6,
                },
              },
              {
                depth: 2,
                itemStyle: {
                  color: "#ccebc5",
                },
                lineStyle: {
                  color: "source",
                  opacity: 0.6,
                },
              },
              
            ],
            lineStyle: {
              curveness: 0.5,
            },
          },
        ],
      };


      // if(option.series.length!==0){
      //   option["dataZoom"]  =[
      //   {   // 这个dataZoom组件，默认控制x轴。
      //       type: 'slider', // 这个 dataZoom 组件是 slider 型 dataZoom 组件
      //       start: 10,      // 左边在 10% 的位置。
      //       end: 60         // 右边在 60% 的位置。
      //   }]
      // }

      myChart_mercor.clear();
      myChart_mercor.setOption(option);
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },

    draw_chart_sca(data, id) {
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);

      let option = {
        xAxis: {},
        yAxis: {},
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
      window.onresize = function () {
        myChart_mercor.resize();
      };
    },
  },
};
</script>


<style>
div#scaterid {
  margin: 0 auto;
}

.geneExp {
  display: flex;
  justify-content: center;
}
</style>
