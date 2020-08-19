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

        <div class="textitem" v-if="geneshow" v-loading="geneloading">
          <p class="card-title">Gene Expression in cell type selected</p>
          <div class="geneExp">
            <img id="singleimg" width="550px" :src="imgUrlBox" />

            <img id="singleimg" width="550px" :src="imgUrlBar" />
          </div>
        </div>
      </el-card>
    </div>

    
      <div class="textitem">
        <el-card v-loading="singleCellCorloading">
        <p
          class="card-title"
        >Top 10 genes correlated with {{this.seargene}} in each cell type selected</p>
        <div>
           <el-row class="selectrow">
          <el-col :span="6">
            <span class="demonstration">DataSet:</span>
            <el-select v-model="CancerType" @change="CancerTypeSelectChange" placeholder="DataSet">
                <el-option
                  v-for="item in canceroptions"
                  :key="item.cancer"
                  :label="item.cancer"
                  :value="item.cancer"
                ></el-option>
              </el-select>
          </el-col>

          <el-col :span="6" >
            <span class="demonstration">Global Cluster:</span>
            <el-select v-model="GlobalCluster" @change="GlobalClusterChange">
                <el-option
                  v-for="item in gloCluoptions"
                  :key="item.glo"
                  :label="item.glo"
                  :value="item.glo"
                ></el-option>
              </el-select>
          </el-col>

           <el-col :span="6">
            <span class="demonstration">Cell Type:</span>
            <el-select v-model="CellType" v-loading="CellTypeLoading">
                <el-option
                  v-for="item in CellTypeCluoptions"
                  :key="item.CellType"
                  :label="item.CellType"
                  :value="item.CellType"
                ></el-option>
              </el-select>
          </el-col>
           <el-col :span="6" :offset="1">
            <el-button @click="searchTable">Search</el-button>
          </el-col>


        </el-row>
         <br>
          <!-- <div id="singleCellCorTumor" class="scaterPlot" style="width: 1200px;height:1000px;"></div> -->
          <el-row>
            <el-table :data="ReactomeTableData" max-height="600" style="width: 100%">
              <el-table-column prop="genea" label="Search Gene" width="180"></el-table-column>
              <el-table-column prop="geneb" label="Gene" width="180"></el-table-column>
              <el-table-column label="COR" prop="r"></el-table-column>
              <el-table-column prop="COEAID" label="COEAID"></el-table-column>
              <el-table-column prop="GlobalCluster" label="GlobalCluster"></el-table-column>
              <el-table-column prop="CellType" label="CellType"></el-table-column>
              <el-table-column prop="CancerType" label="CancerType"></el-table-column>
              <el-table-column prop="SCID" label="SCID"></el-table-column>
            </el-table>
          </el-row>
          <br>
          <el-row>
            <el-pagination
            class="scPagination"
              background
              :page-sizes="[10, 20, 50, 100]"
              :page-size="pageSize"
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
              :current-page="currentPage"
              layout="sizes,prev, pager, next"
              :total="total"
            ></el-pagination>
          </el-row>
        </div>
        </el-card>
      </div>
    

    <el-card v-show="singleCellshow">
      <div class="textitem" v-show="singleCellImmuTumorshow" v-loading="singleCellImmuTumorloading">
        <p class="card-title">Differential expression between tumor and normal per cell type</p>
        <div class="geneExp">
          <div id="singleCellImmuTumor" class="scaterPlot" style="width: 600px;height:400px;"></div>
          <div v-show="singleCellImmuTumorImgshow" v-loading="singleCellImmuTumorImgloading">
            <img id="singleimg" width="550px" height="550px" :src="imgpathBar2" />
          </div>
        </div>
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
          <div id="singleCellImmuResponse" class="scaterPlot" style="width: 600px;height:400px;"></div>

          <div v-show="singleCellImmuResponseImgshow" v-loading="singleCellImmuResponseImgloading">
            <img id="singleimg" width="550px" height="550px" :src="imgpathBar3" />
          </div>
        </div>
      </div>
    </el-card>

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
      currentPage: 1,
      pageSize: 20,
      total: 200,
      CellTypeLoading:false,
      GlobalCluster:"All",
      CellType:"Endothelial",
      CancerType:"BCC",
      singleCellshow: false,
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
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
      this.getTableData(this.seargene);
      this.getcancer();
      this.getgloClu();
      // this.getScaData(this.seargene, "home_scdiffexp_tn", "singleCellImmuTumor");
      // this.getScaData(this.seargene, "home_scdiffexp_rnr", "singleCellImmuResponse");
      this.getDiagramData(this.seargene, "singleCellCorTumor",1,10);
    });
  },

  computed: {
    imgUrlBox: function () {
      return this.imgpathBox;
    },
    imgUrlBar: function () {
      return this.imgpathBar;
    },
    // imgUrlBar2: function () {
    //   return this.imgpathBar2;
    // },
    // imgUrlBar3: function () {
    //   return this.imgpathBar3;
    // },
  },

  methods: {
    handleSizeChange(val) {
      this.pageSize = val;
      this.currentPage =1;
      this.getDiagramData(this.seargene, "singleCellCorTumor", 1, val);
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.getDiagramData(
        this.seargene,
        "singleCellCorTumor",
        val,
        this.pageSize
      );
    },
    Plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.oldseargene = this.seargene;
        this.clickPlot(this.seargene);
      }
    },
    clickPlot() {
      this.singleCellshow = true;
      this.getDiagramData(
        this.seargene,
        "singleCellCorTumor",
        this.currentPage,
        this.pageSize
      );
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
      this.genePlot(this.seargene);
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
            gloclu: this.gloClu,
            subclu: this.subClu.join(","),
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            if (res.data.output[0] === "0") {
              that.geneshow = false;
            } else {
              that.imgpathBox =
                "/tiger/img/" + res.data.output[0].split(",")[0];
              that.imgpathBar =
                "/tiger/img/" + res.data.output[0].split(",")[1];
              // that.imgpathBar2 =
              //   "tiger/img/" + res.data.output[0].split(",")[2];
              // that.imgpathBar3 =
              //   "tiger/img/" + res.data.output[0].split(",")[3];
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

   
    CancerTypeSelectChange(){
      this.GlobalCluster="All"
      this.getCellType()
    },
     GlobalClusterChange(){
      this.getCellType()
    },
    getCellType() {
      this.CellTypeLoading=true
      this.$http
        .get("/tiger/scCelltype.php", {
          params: {
            CancerType: this.CancerType,
            GlobalCluster: this.GlobalCluster,
          },
        })
        .then((res) => {
          this.CellTypeCluoptions = res.data.list;
          this.CellType = res.data.list[0].CellType;
          this.CellTypeLoading=false
        });
    },
    searchTable(){
      this.getDiagramData(this.seargene, "singleCellCorTumor",1,10);
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
              } else {
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

    getDiagramData(gene, id, currentPage, pageSize) {
      this.ReactomeTableData = [];
      this.singleCellCorloading = true;
      this.$http
        .get("/tiger/searchcoeaTable.php", {
          params: {
            gene: gene,
            currentPage: currentPage,
            pageSize: pageSize,
            GlobalCluster:this.GlobalCluster,
            CellType:this.CellType,
            CancerType:this.CancerType
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.ReactomeTableData = res.data.list;
            this.total = res.data.total[0];            
            this.singleCellCorloading = false;
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
                  "/tiger/img/" + res.data.output[0].split(",")[2];
              } else {
                that.singleCellImmuResponseImgshow = true;
                that.singleCellImmuResponseImgloading = false;
                that.imgpathBar3 =
                  "/tiger/img/" + res.data.output[0].split(",")[2];
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
      var that = this;
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);

      let option = {
        xAxis: { name: "Log2FC" },
        yAxis: { name: "P Value" },
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
</style>
