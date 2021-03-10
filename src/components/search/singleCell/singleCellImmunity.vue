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
        <p class="card-title">
          Top 10 genes correlated with {{ this.seargene }} in each cell type
          selected
        </p>
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
              <span class="demonstration">Main Lineage: </span>
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
              <el-select
                v-model="CellType"
                v-loading="CellTypeLoading"
                @change="subClusterChange"
              >
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
      picScattername: "",
      picScatterloading: true,
      MarkerTable: [],
      markerimg: "",
      overviewimg: "",
    };
  },
  mounted() {
    this.CancerTypeSelectChange();
    this.getcancer();
    this.$nextTick(() => {
      this.oldseargene = this.seargene;
      this.searchTable();
      this.getgloClu();
      this.getCellType();
    });
  },

  methods: {
    reset() {},
    plot() {
      if ((this.oldseargene !== this.seargene) | (this.oldseargene === "")) {
        this.reset();
        this.oldseargene = this.seargene;
        console.log(this.seargene);
        this.$refs.singleCellImmunityCorTableRef.plot();
        this.$refs.singlecellmarker.plot();
        this.$refs.singlecelldiffTN.plot();
        this.$refs.singlecelldiffRNR.plot();
      }
    },

    getcancer() {
      this.$http.get("/tiger/singlecelldataset.json").then((res) => {
        this.canceroptions = res.data;
      });
    },
    CancerTypeSelectChange() {
      this.getgloClu();
      // this.$nextTick(() => {
      //   this.getCellType();
      // });
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
          this.getCellType();
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
  },
  components: {
    "v-singleCellImmunityCorTable": singleCellImmunityCorTable,
    "v-singleCellMarker": singleCellMarker,
    "v-singleCellDiffexp": singleCellDiffexp,
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
