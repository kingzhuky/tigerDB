<template>
  <div class="outside">
    <el-card id="scimmucard">
      <el-row id="scImmuInput">
        <el-row>
          <el-col :span="16" :offset="4">
            <p class="scImmuTitle">Select A Dataset</p>
          </el-col>
          <!-- <el-col :span="10" :offset="1">
            <p class="scImmuTitle">Select A Global Cluster</p>
          </el-col> -->
          <!-- <el-col :span="5" :offset="1">
            <p class="scImmuTitle">Select A Sub Cluster</p>
          </el-col> -->
        </el-row>
        <el-row>
          <el-col :span="16" :offset="4" id="homeInput">
              <el-select v-model="cancer" @change="cancerSelectChange"  placeholder="请选择">
                <el-option-group
                  v-for="group in canceroptions"
                  :key="group.label"
                  :label="group.label">
                  <el-option
                    v-for="item in group.options"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value">
                  </el-option>
                </el-option-group>
              </el-select>
          </el-col>
          <!-- <el-col :span="10" :offset="1" id="homeInput">
            <el-select v-model="gloClu" @change="gloCluChange">
              <el-option
                v-for="item in gloCluoptions"
                :key="item.glo"
                :label="item.glo"
                :value="item.glo"
              ></el-option>
            </el-select>
          </el-col> -->
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
              :gloCluoptions="gloCluoptions"
              :is="overviewVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Cell Type Marker" name="celltype">
            <component
              :cancer="cancer"
              :gloclu="gloClu"
              ref="celltypeRef"
              :is="celltypeVue"
            ></component>
          </el-tab-pane>
           <el-tab-pane label="Differential Expression Analysis" name="scdiffexp">
            <component
              :cancer="cancer"
              :gloclu="gloClu"
              ref="diffexpRef"
              :is="diffexpVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Co-expression Analysis" name="coexp">
            <component ref="coexpRef" :CancerType="cancer"  :is="coexpVue"></component>
          </el-tab-pane>
          <el-tab-pane label="Evolution Analysis" name="evolution">
            <component ref="evolutionRef" :cancer="cancer"  :gloCluoptions="gloCluoptions" :is="evolutionVue"></component>
          </el-tab-pane>
          <el-tab-pane label="Cross Talk" name="crosstalk">
          <component 
          :is="crosstalkVue"
          :cancer="cancer"
          :gloclu="gloClu"
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
const werevolution = resolve => require(["./evolution.vue"], resolve);

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
      evolutionVue: "",
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
      gloCluoptions: [ { "glo": "All" }, { "glo": "Tcell" }, { "glo": "Bcell" } ],

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
      this.$http.get("/tiger/singlecelldataset.json").then(res => {
        this.canceroptions = res.data;
      });
    },

    cancerSelectChange() {
      //this.$refs.coexpRef.reset()
      //this.subClucoptions = [];
      this.getgloClu();
      this.activeName = "overview";
      this.$refs.overviewRef.clickPlot();
      this.$refs.coexpRef.CancerTypeSelectChange();
      

    },
    gloCluChange() {
      //this.$refs.coexpRef.reset()
      //this.subClucoptions = [];
      //this.getcrossClu()
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
          //this.gloClu = res.data.list[0].glo;
          //this.getcrossClu();
          
        });
    },
    

    // getcrossClu() {
    //   this.$http
    //     .get("/tiger/sccluster.php", {
    //       params: {
    //         cancer: this.cancer,
    //         gloclu: this.gloClu,
    //         type: "singlecellcluster"
    //       }
    //     })
    //     .then(res => {
    //       this.subClucoptions = res.data.list;
    //       this.subClu = res.data.list;
    //       this.$refs.overviewRef.Plot(this.cancer,
    //       this.gloClu,
    //       this.subClu.join(","));
    //     });
    // },

    analysis() {
      this.carouselShow = false;
      this.activeName = "overview";

      this.$refs.overviewRef.Plot(
        this.cancer,
        this.gloClu
        //this.subClu.join(",")
      );
      this.$refs.diffexpRef.reset();
      this.$refs.celltypeRef.reset();
      //this.$refs.overviewRef.getcrossClu(cancer);
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
          //this.$refs.celltypeRef.reset();
          this.$refs.celltypeRef.plot();
          break;
        case "scdiffexp":
          this.diffexpVue = werdiffexp;
          //this.$refs.diffexpRef.reset();
          this.$refs.diffexpRef.plot();
          break;
        case "coexp":
          this.coexpVue = wercoexp;
          //this.$refs.coexpRef.plot();
          break;
        case "crosstalk":
          this.crosstalkVue = wercrosstalk;
          this.$refs.crosstalkRef.reset();
          break;
        case "evolution":
          this.evolutionVue = werevolution;
          //this.$refs.evolutionRef.reset();
          break;
      }
    }
  }
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