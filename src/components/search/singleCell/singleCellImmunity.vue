<template>
  <div>
    <el-card>
      <v-singleCellMarker
        ref="singlecellmarker"
        :seargene="seargene"
        conditi="Marker"
        title="Expression in different cell types"
      ></v-singleCellMarker>
    </el-card>
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
      <v-singleCellDiffexp
        ref="singlecelldiffTN"
        :seargene="seargene"
        conditi="home_scdiffexp_tn"
        title="Differential expression between tumor and normal per cell type"
      ></v-singleCellDiffexp>
      <v-singleCellDiffexp
        ref="singlecelldiffRNR"
        :seargene="seargene"
        conditi="home_scdiffexp_rnr"
        title="Differential expression between response and non-response per cell type"
      ></v-singleCellDiffexp>
    </el-card>
  </div>
</template>

<script>
import singleCellImmunityCorTable from "./singleCellImmunityCorTable.vue";
import singleCellDiffexp from "./singleCellImmunityExpTable.vue";
import singleCellMarker from "./singleCellImmunityMarkerTable.vue";
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
      oldseargene: "",
      imgpathBar3: "",
      picScattername: "",
      picScatterloading: true,
      DiffExpTumorTableData: [],
      MarkerTable: [],
      markerimg: "",
      overviewimg: "",
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
      this.getTableData(this.seargene);
      this.searchTable();
      this.getcancer();
      this.getgloClu();
      this.getCellType();
    });
  },
  components: {
    "v-singleCellImmunityCorTable": singleCellImmunityCorTable,
    "v-singleCellMarker": singleCellMarker,
    "v-singleCellDiffexp": singleCellDiffexp,
  },

  computed: {
    // imgUrlBar: function () {
    //   return this.imgpathBar;
    // },
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
            // console.log(this.CellType)
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
            this.MarkerTable = res.data.tabledata
            this.draw_chart(res.data.list, "scaterid");
            this.loading = false;
          }
        })
        .catch((error) => {
          console.log(error);
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
              // console.log(that.imgpathBox)
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
