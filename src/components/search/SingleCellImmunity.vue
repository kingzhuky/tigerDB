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
            <img id="singleimg" :src="imgUrlBox" />

            <img id="singleimg" :src="imgUrlBar" />
          </div>
        </div>
      </el-card>
    </div>

    <div class="textitem">
      <el-card >
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
                    :label="item.label"
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
                  :key="item.glo"
                  :label="item.glo"
                  :value="item.glo"
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
          <v-singleCellImmunityCorTable ref="singleCellImmunityCorTableRef" :seargene="seargene" :CancerType="CancerType" :GlobalCluster="GlobalCluster" :CellType="CellType"></v-singleCellImmunityCorTable>
        </div>
      </el-card>
    </div>

    <el-card>
      <div class="textitem" v-show="singleCellImmuTumorshow" v-loading="singleCellImmuTumorloading">
        <p class="card-title">Differential expression between tumor and normal per cell type</p>
        <div class="geneExp">
          <div id="singleCellImmuTumor" class="scaterPlot" style="width: 600px;height:400px;"></div>
          <div v-show="singleCellImmuTumorImgshow" v-loading="singleCellImmuTumorImgloading">
            <img id="singleimg" :src="imgpathBar2" />
          </div>
        </div>

        <el-table
            :data="DiffExpTumorTableData"
              max-height="800"
              style="width: 100%"
            >
               <el-table-column label="CancerType" prop="CancerType"></el-table-column>
              <el-table-column prop="GlobalCluster" label="GlobalCluster"></el-table-column>
              <el-table-column prop="CellType" label="CellType"></el-table-column>
              <el-table-column prop="Log2FoldChange" label="Log2FoldChange" width="180"></el-table-column>
              <el-table-column prop="P_Value" label="P-Value" width="180"></el-table-column>
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
          <div id="singleCellImmuResponse" class="scaterPlot" style="width: 600px;height:400px;"></div>

          <div v-show="singleCellImmuResponseImgshow" v-loading="singleCellImmuResponseImgloading">
            <img id="singleimg" :src="imgpathBar3" />
          </div>
        </div>
          <el-table
            :data="DiffExpResponseableData"
              max-height="800"
              style="width: 100%"
            >
              <el-table-column label="CancerType" prop="CancerType"></el-table-column>
              <el-table-column prop="GlobalCluster" label="GlobalCluster"></el-table-column>
              <el-table-column prop="CellType" label="CellType"></el-table-column>
              <el-table-column prop="Log2FoldChange" label="Log2FoldChange" width="180"></el-table-column>
              <el-table-column prop="P_Value" label="P-Value" width="180"></el-table-column>
       
            </el-table>
      </div>
    </el-card>
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
      DiffExpTumorTableData:[],
      DiffExpTumorTableData:[]
    };
  },
  mounted() {
    this.$nextTick(() => {
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

      this.getcancer();
      this.getgloClu();
      this.getCellType()
      //this.getDiagramData(this.seargene, "singleCellCorTumor", 1, 10);
    });
  },
 components: {
    "v-singleCellImmunityCorTable": () => import("./singleCellImmunityCorTable.vue"),
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
    reset(){
      this.DiffExpTumorTableData=[]
      this.DiffExpTumorTableData=[]
      this.imgpathBox=""
      this.imgpathBar=""
    },
  
    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.reset()
        this.$refs.singleCellImmunityCorTableRef.reset();

        this.oldseargene = this.seargene;
        //this.clickPlot(this.seargene);
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
    // clickPlot() {
    //   this.getDiagramData(
    //     this.seargene,
    //     "singleCellCorTumor",
    //     this.currentPage,
    //     this.pageSize
    //   );

    //   this.genePlot(this.seargene);
    // },

    // getRowKeys: function (row) {
    //   return row.geneb;
    // },
    // diffExpRespontableExpand: function (row, expandedRows) {
      
    //   var that = this;
    //   if (expandedRows.length) {
    //     that.expands = [];
    //     if (row) {
    //       that.expands.push(row.geneb);
    //       console.log(that.expands)
    //     }
    //   } else {
    //     that.expands = [];
    //     console.log(that.expands)
    //   }
     
    //   this.picScatterPlot(
    //     row.datasetid,
    //     row.GlobalCluster,
    //     row.genea,
    //     row.geneb,
    //     row.CellType
    //   );
    // },

    // picScatterPlot(datasetid, GlobalCluster, genea, geneb, CellType) {
    //    console.log(
    //     datasetid,
    //     GlobalCluster,
    //     genea,
    //     geneb,
    //     CellType
    //   )
    //   var that = this;
    //   that.detailimgShow = true;

    //   that.picScatterloading = true;
    //   var params = {
    //        cancer: datasetid,
    //       gloclu: GlobalCluster,
    //       gene: genea,
    //       clickgene: geneb,
    //       cluster: CellType,
    //       method: "pearson",
    //     };
    //   this.$http
    //     .get("/tiger/scimmucoexpdetail.php", {
    //       params: params,
    //     })
    //     .then(function (res) {
    //       if (res.data.status == 0) {
    //         that.picScattername = res.data.output[0];
    //         that.picScatterloading = false;
    //       } else {
    //         that.detailimgShow = false;
    //       }
    //     })
    //     .catch(function (res) {
    //       console.log(res);
    //     });
    // },

    // genePlot(clickgene) {
    //   var that = this;
    //   that.geneloading = true;
    //   that.geneshow = true;
    //   this.$http
    //     .get("/tiger/scimmudiffexpdetailgene.php", {
    //       params: {
    //         cancer: this.cancer,
    //         gene: clickgene,
    //         gloclu: this.gloClu,
    //         subclu: this.subClu.join(","),
    //       },
    //     })
    //     .then(function (res) {
    //       if (res.data.status == 0) {
    //         if (res.data.output[0] === "0") {
    //           that.geneshow = false;
    //         } else {
    //           that.imgpathBox =
    //             "/tiger/img/" + res.data.output[0].split(",")[0];
    //           that.imgpathBar =
    //             "/tiger/img/" + res.data.output[0].split(",")[1];
    //           that.geneshow = true;
    //         }
    //         that.geneloading = false;
    //       }
    //     })
    //     .catch(function (res) {
    //       console.log(res);
    //     });
    // },

    getcancer() {
      this.$http.get("/tiger/singlecelldataset.json").then((res) => {
        this.canceroptionsTable = res.data;
      });
    },
    cancerSelectChange() {
      this.getgloClu();
    },

    CancerTypeSelectChange() {
      this.GlobalCluster = "All";
      this.getCellType();
    },
    GlobalClusterChange() {
      this.getCellType();
    },
    subClusterChange(){
      this.searchTable()
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
          if(res.data.status===200){
            this.CellTypeLoading = false;
            this.CellTypeCluoptions = res.data.list;
            this.CellType = res.data.list[0].CellType;
            this.searchTable()
          }
         
          
        });
    },
    searchTable() {
      this.$refs.singleCellImmunityCorTableRef.getDiagramData(this.seargene, "singleCellCorTumor", 1, 10);
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
                this.DiffExpTumorTableData=res.data.infosTable
              } else {
                this.DiffExpResponseableData=res.data.infosTable
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

    // getDiagramData(gene, id, currentPage, pageSize) {
    //   this.ReactomeTableData = [];
    //   this.singleCellCorloading = true;
    //   this.$http
    //     .get("/tiger/searchcoeaTable.php", {
    //       params: {
    //         gene: gene,
    //         currentPage: currentPage,
    //         pageSize: pageSize,
    //         GlobalCluster: this.GlobalCluster,
    //         CellType: this.CellType,
    //         CancerType: this.CancerType,
    //       },
    //     })
    //     .then((res) => {
    //       if (res.data.status === 200) {
    //         this.ReactomeTableData = res.data.list;
    //         this.total = res.data.total[0];
    //         this.singleCellCorloading = false;
    //       }
    //     })
    //     .catch((error) => {
    //       console.log(error);
    //     });
    // },

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
.detailimg {
    text-align: center;
}
</style>
