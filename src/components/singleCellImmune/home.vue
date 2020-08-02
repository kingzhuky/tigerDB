<template>
  <div class="outside">
    <el-card id="scimmucard">
      <el-row id="scImmuInput">
        <el-row>
          <el-col :span="11" :offset="1">
            <p class="scImmuTitle">Select A Cancer Type</p>
          </el-col>
          <el-col :span="10" :offset="1">
            <p class="scImmuTitle">Select A Global Cluster</p>
          </el-col>
          <!-- <el-col :span="5" :offset="1">
            <p class="scImmuTitle">Select A Sub Cluster</p>
          </el-col> -->
        </el-row>
        <el-row>
          <el-col :span="11" :offset="1" id="homeInput">
            <el-select v-model="cancer" @change="cancerSelectChange" placeholder="Cancer">
              <el-option
                v-for="item in canceroptions"
                :key="item.cancer"
                :label="item.cancer"
                :value="item.cancer"
              ></el-option>
            </el-select>
          </el-col>
          <el-col :span="10" :offset="1" id="homeInput">
            <el-select v-model="gloClu" @change="gloCluChange">
              <el-option
                v-for="item in gloCluoptions"
                :key="item.glo"
                :label="item.glo"
                :value="item.glo"
              ></el-option>
            </el-select>
          </el-col>
          <!-- <el-col :span="5" :offset="1" id="homeInput">
            <el-select v-model="subClu"  multiple>
              <el-option
                v-for="item in subClucoptions"
                :key="item.sub"
                :label="item.sub"
                :value="item.sub"
              ></el-option>
            </el-select>
          </el-col> -->
          <!-- <el-col :span="7" :offset="1">
            <el-button id="homebt" @click="analysis">Go</el-button>
          </el-col> -->
        </el-row>
      </el-row>
    </el-card>

    <div>
      <el-card class="box-card-heatmap">
        <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="werTab">
          <el-tab-pane label="Overview" name="overview">
            <component
              ref="overviewRef"
              :cancer="cancer"
              :gloclu="gloClu"
              :subClucoptions="subClucoptions"
              :subClu="subClu"
              :is="overviewVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Cell Type Marker" name="celltype">
            <component
              :cancer="cancer"
              :gloclu="gloClu"
              :subClucoptions="subClucoptions"
              :subClu="subClu"
              ref="celltypeRef"
              :is="celltypeVue"
            ></component>
          </el-tab-pane>
           <el-tab-pane label="Differential Expression Analysis" name="scdiffexp">
            <component
              :cancer="cancer"
              :gloclu="gloClu"
              :subClucoptions="subClucoptions"
              :subClu="subClu"
              ref="diffexpRef"
              :is="diffexpVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Co-expression Analysis" name="coexp">
            <component ref="coexpRef" :cancer="cancer" :gloclu="gloClu" :is="coexpVue"></component>
          </el-tab-pane>
          <el-tab-pane label="Cross Talk" name="crosstalk">
          <component 
          :is="crosstalkVue"
          :cancer="cancer"
          :gloclu="gloClu"
          :subClucoptions="subClucoptions"
          :subClu="subClu"
          ref="crosstalkRef"
          ></component>
          </el-tab-pane>
        </el-tabs>
      </el-card>
    </div>
  </div>
</template>

<script>
const weroverview = resolve => require(["./overview.vue"], resolve);
const wercoexp = resolve => require(["./coExp.vue"], resolve);
const werdiffexp = resolve => require(["./diffExp.vue"], resolve);
const wercelltype = resolve => require(["./celltype.vue"], resolve);
const wercrosstalk = resolve => require(["./crosstalk.vue"], resolve);

export default {
  data() {
    return {
      carouselShow: false,
      activeName: "overview",
      diffexpVue: "",
      diffexpVue: "",
      coexpVue: "",
      evoluVue: "",
      celltypeVue: "",
      crosstalkVue: "",
      norgene: "CD3D",
      qvalcutoff: "0.25",
      expcutoff: 0.25,
      expcutoff2: 0.75,
      colany: "Spearman",
      dataList: [],
      dataListOption: ["TCGA", "TCAG", "ABCD"],
      gene: "ERBB2",
      genelist: "",
      cancer: "BCC",
      gloClu: "All",
      subClu:[
      "B-cell",
      "CAF",
      "DC",
      "Endothelial",
      "Macrophages",
      "Melanocytes",
      "Myofibroblasts",
      "NK",
      "pDC",
      "Plasma",
      "T-cell",
      "Tumor",
    ],
      canceroptions: [
        {
          value: "ACC",
          label: "ACC"
        },
        {
          value: "BCC",
          label: "BCC"
        },
        {
          value: "BLCA",
          label: "BLCA"
        },
        {
          value: "BRCA",
          label: "BRCA"
        },
        {
          value: "CESC",
          label: "CESC"
        },
        {
          value: "CHOL",
          label: "CHOL"
        },
        {
          value: "COAD",
          label: "COAD"
        },
        {
          value: "DLBC",
          label: "DLBC"
        },
        {
          value: "ESCA",
          label: "ESCA"
        },
        {
          value: "GBM",
          label: "GBM"
        },
        {
          value: "HNSC",
          label: "HNSC"
        },
        {
          value: "KICH",
          label: "KICH"
        },
        {
          value: "KIRC",
          label: "KIRC"
        },
        {
          value: "KIRP",
          label: "KIRP"
        },
        {
          value: "LIHC",
          label: "LIHC"
        },
        {
          value: "LAML",
          label: "LAML"
        },
        {
          value: "LGG",
          label: "LGG"
        },
        {
          value: "LUAD",
          label: "LUAD"
        },
        {
          value: "LUSC",
          label: "LUSC"
        },
        {
          value: "MESO",
          label: "MESO"
        },
        {
          value: "OV",
          label: "OV"
        },
        {
          value: "PAAD",
          label: "PAAD"
        },
        {
          value: "PCPG",
          label: "PCPG"
        },
        {
          value: "READ",
          label: "READ"
        },
        {
          value: "SKCM",
          label: "SKCM"
        },
        {
          value: "SARC",
          label: "SARC"
        },
        {
          value: "STAD",
          label: "STAD"
        },
        {
          value: "TGCT",
          label: "TGCT"
        },
        {
          value: "THCA",
          label: "THCA"
        },
        {
          value: "THYM",
          label: "THYM"
        },
        {
          value: "TNBC",
          label: "TNBC"
        },
        {
          value: "UCEC",
          label: "UCEC"
        },
        {
          value: "UCS",
          label: "UCS"
        }
      ],
      gloCluoptions: [],
      allsubClucoptions: [
        {
          value: "B-cell",
          label: "B-cell"
        },
        {
          value: "CAF",
          label: "CAF"
        },
        {
          value: "DC",
          label: "DC"
        },
        {
          value: "Endothelial",
          label: "Endothelial"
        },
        {
          value: "Macrophages",
          label: "Macrophages"
        },
        {
          value: "Myofibroblasts",
          label: "Myofibroblasts"
        },
        {
          value: "NK",
          label: "NK"
        },
        {
          value: "pDC",
          label: "pDC"
        },
        {
          value: "Plasma",
          label: "Plasma"
        },
        {
          value: "T-cell",
          label: "T-cell"
        },
        {
          value: "Tumor",
          label: "Tumor"
        }
      ],
      subClucoptions: [],
      Signatures: ""
    };
  },

  created() {
    this.overviewVue = weroverview;
  },
  mounted() {
    this.getcancer();
    this.getgloClu();
  },

  methods: {
    getcancer() {
      this.$http.get("/tiger/sccancer.php").then(res => {
        this.canceroptions = res.data.list;
      });
    },

    cancerSelectChange() {
      //this.$refs.coexpRef.reset()
      this.subClucoptions = [];
      this.getgloClu();
      this.activeName = "overview";
    },
    gloCluChange() {
      //this.$refs.coexpRef.reset()
      this.subClucoptions = [];
      this.getcrossClu()
      this.activeName = "overview";
      
      //this.$refs.diffexpRef.reset();
      //this.$refs.diffexpRef.getTableData();
    },


    getgloClu() {
      this.$http
        .get("/tiger/scglocluster.php", {
          params: {
            cancer: this.cancer,
            type: "singlecellcluster"
          }
        })
        .then(res => {
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
            type: "singlecellcluster"
          }
        })
        .then(res => {
          this.subClucoptions = res.data.list;
          this.subClu = res.data.list;
          this.$refs.overviewRef.Plot(this.cancer,
          this.gloClu,
          this.subClu.join(","));
        });
    },

    analysis() {
      this.carouselShow = false;
      this.activeName = "overview";

      this.$refs.overviewRef.Plot(
        this.cancer,
        this.gloClu,
        this.subClu.join(",")
      );
      this.$refs.diffexpRef.reset();
      this.$refs.celltypeRef.reset();
      this.$refs.overviewRef.getcrossClu(cancer);
    },
    handleClick(tab, event) {
      this.checkVue(tab.name);
    },
    checkVue(name) {
      switch (name) {
        case "overview":
          this.overviewVue = weroverview;
          break;
        case "celltype":
          this.celltypeVue = wercelltype;
          this.$refs.celltypeRef.plot();
          break;
        case "scdiffexp":
          this.diffexpVue = werdiffexp;
          this.$refs.diffexpRef.plot();
          break;
        case "coexp":
          this.coexpVue = wercoexp;
          this.$refs.coexpRef.plot();
          break;
        case "crosstalk":
          this.crosstalkVue = wercrosstalk;
          this.$refs.crosstalkRef.reset();
          break;
      }
    }
  },
  components: {}
};
</script>

<style>
@import "../immuneResponse/style.css";
.scImmuTitle {
  color: rgb(20, 146, 140);
  font-size: 18px;
}
.homedesrc {
  font-size: 23px !important;
  line-height: 30px !important;
}

#homebt {
  background-color: rgb(20, 146, 140) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}
#scImmuInput .el-select {
  width: 100% !important;
}

div#scImmuInput {
  padding: 10px 0;
}
div#scimmucard {
  margin-bottom: 10px;
}
</style>