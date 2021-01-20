<template>
  <div>
    <div class="textitem">
      <el-card>
        <p class="card-title">Expression in different cell types</p>
        <el-row>
          <el-col :span="16" push="3" v-loading="loading">
            <div id="scaterid" style="width: 1000px;height:500px;"></div>
            <!-- <div id="scaterid" style="width: 100%;"></div> -->
            <!-- <div id="scaterid" width="100%"></div> -->
          </el-col>
        </el-row>
        <el-table 
          :data="MarkerTable" 
          max-height="600" 
          style="width: 100%"
          :row-key="getRowKeys"
          :expand-row-keys="expands"
          @expand-change="markertableExpand"
          v-loading="loading"
        >
          <el-table-column type="expand" >
            <template slot-scope="scope">
              <div class="detailimg" v-loading="geneloading">
                <div v-show="geneshow">
                  <!-- <img id="singleimg" :src="imgpathBox" />
                  <img id="singleimg" :src="imgUrlBar" /> -->
                  <el-row v-show="geneshow" class="scdetailimg">
                    <!-- <p class="card-title">tSNE</p> -->
                  <el-col :span="6" style="position:relative;left:20px;top:0px;">
                    <p class="imgtitle">Cell Types</p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + overviewimg.split(',')[0]+'.png'"
                      @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + markerimg.split(',')[1],'tiger/img/' + markerimg.split(',')[0]])">
                  </el-col>
                  <el-col :span="6" style="position:relative;left:100px;top:0px;">
                    <p class="imgtitle">UMAP Plot of {{scope.row.CellType}} Types</p>
                    <img
                      id="singleimg"
                      fit="fill"
                      width="100%"
                      :src="'tiger/img/' + markerimg.split(',')[1]"
                      @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + markerimg.split(',')[1],'tiger/img/' + markerimg.split(',')[0]])">
                  </el-col>
                  <el-col :span="12" style="position:relative;left:40px;top:0px;">
                    <p class="imgtitle">Boxplot of {{seargene}} Expression</p>
                    <img
                      id="singleimg"
                      fit="fill"
                      height="250px"
                      :src="'tiger/img/' + markerimg.split(',')[0]"
                      @click="previewImg(['tiger/img/' + overviewimg.split(',')[0]+'.png','tiger/img/' + markerimg.split(',')[1],'tiger/img/' + markerimg.split(',')[0]])">
                  </el-col>
                  </el-row>
                </div>
                <div v-show="!geneshow">no result</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="CancerType" label="Cancer Type" width="400%" sortable></el-table-column>
          <el-table-column prop="GlobalCluster" label="Global Cluster" width="180%" sortable></el-table-column>
          <el-table-column prop="CellType" label="Cell Type" sortable></el-table-column>
          <el-table-column prop="Log2FoldChange" label="Log2 ( Fold Change )" sortable></el-table-column>
        </el-table>
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
              <span class="demonstration">DataSet: </span>
              <el-select
                v-model="CancerType"
                @change="CancerTypeSelectChange"
                placeholder="DataSet"
              >
                <el-option-group
                  v-for="group in canceroptions"
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
              <span class="demonstration">Global Cluster: </span>
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
              <span class="demonstration">Cell Type: </span>
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
        </div>
          <el-table
              max-height="600"
              :data="DiffExpTumorTableData"
              :row-key="getRowKeys"
              :expand-row-keys="expands_tn"
              @expand-change="diffExpTNtableExpand"
              style="width: 100%"
            >
            <el-table-column type="expand" >
              <template slot-scope="scope">
                <div class="detailimg" v-loading="singleCellImmuTumorImgloading">
                  <!-- <img width="300px" :src="imgpathBar2" v-show="singleCellImmuTumorImgshow" /> -->
                  <el-row class="scdetailimg" v-show="singleCellImmuTumorImgshow" >
                    <el-col :span="6" >
                      <p class="imgtitle">Cell Types</p>
                      <img
                        id="singleimg"
                        fit="fill"
                        width="100%"
                        :src="'tiger/img/' + diffexpimgTN.split(',')[0] + '.png'"
                        @click="previewImg(['tiger/img/' + diffexpimgTN.split(',')[0] + '.png','tiger/img/' + diffexpimgTN.split(',')[1] + '.png','tiger/img/' + diffexpimgTN.split(',')[2] + '.png'])">
                    </el-col>
                    <el-col :span="6">
                      <p class="imgtitle">UMAP Plot of {{seargene}} Expression</p>
                      <img
                        id="singleimg"
                        fit="fill"
                        width="100%"
                        :src="'tiger/img/' + diffexpimgTN.split(',')[1] + '.png'"
                        @click="previewImg(['tiger/img/' + diffexpimgTN.split(',')[0] + '.png','tiger/img/' + diffexpimgTN.split(',')[1] + '.png','tiger/img/' + diffexpimgTN.split(',')[2] + '.png'])">
                    </el-col>
                    <el-col :span="12">
                      <div class="imgspan"> 
                      <p class="imgtitle">Boxplot of {{seargene}} Expression</p>
                        <img
                        id="singleimg"
                        fit="fill"
                        height="250px"
                        :src="'tiger/img/' + diffexpimgTN.split(',')[2] + '.png'"
                        @click="previewImg(['tiger/img/' + diffexpimgTN.split(',')[0] + '.png','tiger/img/' + diffexpimgTN.split(',')[1] + '.png','tiger/img/' + diffexpimgTN.split(',')[2] + '.png'])">
                      </div>
                    </el-col>
                  </el-row> 
                  <div v-show="!singleCellImmuTumorImgshow">no result</div>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="CancerType" label="Cancer Type" width="400%" sortable></el-table-column>
            <el-table-column prop="datasetid" label="Dataset ID" width="120%" sortable></el-table-column>
            <el-table-column prop="GlobalCluster" label="Global Cluster" sortable></el-table-column>
            <el-table-column prop="CellType" label="Cell Type" sortable></el-table-column>
            <el-table-column prop="Log2FoldChange" label="Log2 Fold Change" sortable></el-table-column>
            <el-table-column prop="P_Value" label="-log10 (P Value)" sortable></el-table-column>
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
        </div>
        <el-table
          max-height="600"
          :data="DiffExpResponseableData"
          :row-key="getRowKeys"
          :expand-row-keys="expands_rnr"
          @expand-change="diffExpRNRtableExpand"
          style="width: 100%"
        >
          <el-table-column type="expand" >
            <template slot-scope="scope">
              <div class="detailimg" v-loading="singleCellImmuResponseImgloading">
                <!-- <img width="300px" :src="imgpathBar3" v-show="singleCellImmuResponseImgshow" /> -->
                  <el-row class="scdetailimg" v-show="singleCellImmuResponseImgshow" >
                    <el-col :span="6" >
                      <p class="imgtitle">Cell Types</p>
                      <img
                        id="singleimg"
                        fit="fill"
                        width="100%"
                        :src="'tiger/img/' + diffexpimgRNR.split(',')[0] + '.png'"
                        @click="previewImg(['tiger/img/' + diffexpimgRNR.split(',')[0] + '.png','tiger/img/' + diffexpimgRNR.split(',')[1] + '.png','tiger/img/' + diffexpimgRNR.split(',')[2] + '.png'])">
                    </el-col>
                    <el-col :span="7">
                      <p class="imgtitle">UMAP Plot of {{seargene}} Expression</p>
                      <img
                        id="singleimg"
                        fit="fill"
                        width="100%"
                        :src="'tiger/img/' + diffexpimgRNR.split(',')[1] + '.png'"
                        @click="previewImg(['tiger/img/' + diffexpimgRNR.split(',')[0] + '.png','tiger/img/' + diffexpimgRNR.split(',')[1] + '.png','tiger/img/' + diffexpimgRNR.split(',')[2] + '.png'])">
                    </el-col>
                    <el-col :span="11">
                      <div class="imgspan"> 
                      <p class="imgtitle">Boxplot of {{seargene}} Expression</p>
                        <img
                        id="singleimg"
                        fit="fill"
                        height="250px"
                        :src="'tiger/img/' + diffexpimgRNR.split(',')[2] + '.png'"
                        @click="previewImg(['tiger/img/' + diffexpimgRNR.split(',')[0] + '.png','tiger/img/' + diffexpimgRNR.split(',')[1] + '.png','tiger/img/' + diffexpimgRNR.split(',')[2] + '.png'])">
                      </div>
                    </el-col>
                  </el-row> 
                <div v-show="!singleCellImmuResponseImgshow">no result</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="CancerType" label="Cancer Type" width="400%" sortable></el-table-column>
          <el-table-column prop="datasetid" label="Dataset ID" width="120%" sortable></el-table-column>
          <el-table-column prop="GlobalCluster" label="Global Cluster" sortable></el-table-column>
          <el-table-column prop="CellType" label="Cell Type" sortable></el-table-column>
          <el-table-column prop="Log2FoldChange" label="Log2 Fold Change" sortable></el-table-column>
          <el-table-column prop="P_Value" label="-log10 (P Value)" sortable></el-table-column>
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
      expands_tn: [],
      expands_rnr: [],
      detailimgShow: true,
      currentPage: 1,
      pageSize: 20,
      total: 200,
      CellTypeLoading: false,
      GlobalCluster: "All",
      CellType: "T cell",
      CancerType: "CAC",
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
      cancer: "PDAC",
      CellTypeExp: "T cell",
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
      picScattername: "",
      picScatterloading: true,
      DiffExpTumorTableData: [],
      MarkerTable: [],
      markerimg: "",
      overviewimg: "",
      diffexpimgTN: "",
      diffexpimgRNR: "",
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
        this.canceroptions = res.data;
      });
    },
    cancerSelectChange() {
      this.getgloClu();
      this.getCellType();
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
            console.log(this.CellType)
            this.$refs.singleCellImmunityCorTableRef.getDiagramData(
              this.seargene,
              "singleCellCorTumor",
              this.CancerType,
              this.GlobalCluster,
              this.CellType,
              1,
              10
            );
          }
        });
    },
    searchTable() {
      this.$refs.singleCellImmunityCorTableRef.getDiagramData(
        this.seargene,
        "singleCellCorTumor",
        this.CancerType,
        this.GlobalCluster,
        this.CellType,
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
      // console.log("data:")
      // console.log(data)
      // console.log("cancer:")
      // console.log(cancer)
      var option2 = {
        title: {
          text: "Cell Type Marker\n ( |Log2FC| )\n",
          textStyle: {
            color: '#333',
            lineHeight: 120,
            height: 30,
            fontFamily: 'Arial',
          }
          // link: "https://github.com/pissang/echarts-next/graphs/punch-card",
        },
        legend: {
          data: ["Punch Card"],
          left: "right",
        },
        polar: {},
        radiusAxis: {
          type: "value",
          data: days,
          axisLine: {
            show: true,
          },
          axisLabel: {
            rotate: 45,
            interval: 0
          },
        },
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
          axisLabel: {
            interval: 0,
            margin: 12,
            // rotate: 45,
          },
        },
        series: [
          {
            name: "Cell Type Marker",
            type: "scatter",
            coordinateSystem: "polar",
            large: true,
            data: data,
            symbolSize: 15,
            animation: false,
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
            // console.log(Object.values(res.data.cancer))
            // console.log("data.list:")
            // console.log(res.data.list)
            // var new_rows = [];// matrix key .替换为_
            // for (const row of res.data.tabledata) {
            //   var new_row = {}
            //   for (const key in row) {
            //     let new_key = key.replace(".",",")
            //     new_row[new_key] = row[key]
            //   }
            //   new_row["id"] = this.getRowKeys(new_row)
            //   new_rows.push(new_row)
            // }
            // this.MarkerTable = new_rows  // matrix key .替换为_

            this.MarkerTable = res.data.tabledata
            console.log("data.table:")
            console.log(this.MarkerTable)
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
        this.diffexpimgTN = "";
        this.singleCellImmuTumorloading = true;
      } else {
        this.singleCellImmuResponseshow = true;
        this.singleCellImmuResponseImgshow = false;
        this.singleCellImmuResponseloading = true;
        this.diffexpimgRNR = "";
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
            type: "exp",
            gloclu: gloclu,
            celltype: subClu,
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
                  "/tiger/img/" + res.data.output[0].split(",")[2] + '.png';
                that.diffexpimgTN = res.data.output[0];
                Vue.se
              } else {
                that.singleCellImmuResponseImgshow = true;
                that.singleCellImmuResponseImgloading = false;
                that.imgpathBar3 =
                  "/tiger/img/" + res.data.output[0].split(",")[2] + '.png';
                that.diffexpimgRNR = res.data.output[0];
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
    markerPlot(datasetid, glocluster, celltype){
      var that = this;
      that.geneloading = true;
      that.geneshow = true;
      that.imgpathBox = ""
      that.imgpathBar = ""
      this.$http
        .get("/tiger/scimmudiffexpdetailgene.php", {
          params: {
            cancer: datasetid,
            celltype: celltype,
            type: "celltype",
            gene: that.seargene,
            gloclu: glocluster
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            if (res.data.output[0] === "0") {
              that.geneshow = false;
              //alert("no gene file");
            } else {
              that.imgpathBox = 'tiger/img/' + res.data.output[0].split(",")[0];
              console.log(that.imgpathBox)
              that.markerimg = res.data.output[0];
            }
            that.evoluloading = false;
            that.geneloading = false;
          }
          if (res.data.status2 == 0) {
            if (res.data.output2[0] === "0") {
              //that.evolushow2 = false;
              //alert("no gene file");
            } else {
              // that.evolushow2 = true;
              setTimeout((that.overviewimg = res.data.output2[0]), 1000);
            }
            //that.evoluplots = res.data.output[0];
          }
        })
        .catch(function (res) {
          console.log(res);
        });
        // this.$http
        //   .get("/tiger/scimmudiffexpdetailgene.php", {
        //     params: {
        //       cancer: this.cancer,
        //       celltype: celltype,
        //       type: "celltype",
        //       gene: gene,
        //       gloclu: gloclu
        //     },
        //   })
        //   .then(function (res) {
        //     if (res.data.status == 0) {
        //       if (res.data.output[0] === "0") {
        //         that.evolushow = false;
        //         //alert("no gene file");
        //       } else {
        //         that.evolushow = true;
        //         that.evoluplots = res.data.output[0];
        //       }
        //       //that.evoluplots = res.data.output[0];
        //       that.evoluloading = false;
        //     }

        //   })
        //   .catch(function (res) {
        //     console.log(res);
        //   });
    },
        
    draw_chart_sca(data, id) {
      var that = this;
      var targetdiv = document.getElementById(id);
      //let myChart_mercor = this.$echarts.init(targetdiv);
      //cdn替换为
      let myChart_mercor = window.echarts.init(targetdiv);

      let option = {
        xAxis: { name: "Log2FC" },
        yAxis: {
          name: "–log10(P Value)",
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

      // myChart_mercor.on("click", function (param) {
      //   if (param.componentSubType === "scatter") {
      //     //console.log(param.data);
      //     that.differentialExpressionPlot(
      //       param.data[2],
      //       param.data[3],
      //       param.data[4],
      //       id
      //     );
      //   }
      // });

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
    markertableExpand: function (row, expandedRows) {
      var that = this;
      if (expandedRows.length) {
        that.expands = [];
        if (row) {
          that.expands.push((row.datasetid + row.GlobalCluster + row.CellType).replace(/\ /g,'_'));
        }
      } else {
        that.expands = [];
      }
      // console.log(row)
      this.markerPlot(row.datasetid,row.GlobalCluster,row.CellType);
    },
    getRowKeys: function (row) {
      return (row.datasetid + row.GlobalCluster + row.CellType).replace(/\ /g,'_');
    },
    getRowKeys2: function (row) {
      return row.id;
    },
    diffExpTNtableExpand: function (row, expandedRows) {
      var that = this;
      if (expandedRows.length) {
        that.expands_tn = [];
        if (row) {
          that.expands_tn.push((row.datasetid + row.GlobalCluster + row.CellType).replace(/\ /g,'_'));
        }
      } else {
        that.expands_tn = [];
      }
      console.log(that.expands_tn)

      this.differentialExpressionPlot(row.datasetid, row.GlobalCluster, row.CellType, "singleCellImmuTumor");
    },
    diffExpRNRtableExpand: function (row, expandedRows) {
      var that = this;
      if (expandedRows.length) {
        that.expands_rnr = [];
        if (row) {
          that.expands_rnr.push((row.datasetid + row.GlobalCluster + row.CellType).replace(/\ /g,'_'));
        }
      } else {
        that.expands_rnr = [];
      }

      this.differentialExpressionPlot(row.datasetid, row.GlobalCluster, row.CellType, "singleCellImmuResponse");
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
