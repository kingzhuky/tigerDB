<template>
  <div class="outside">
    <el-card id="scimmucard">
      <el-row id="scImmuInput">
        <el-row>
          <el-col span="4">
            <select-cancer-icon
              :imgurl="IconBladder"
              IconName="haha">
            </select-cancer-icon>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="20" :offset="2">
            <p class="scImmuTitle">Select A Dataset</p>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="20" :offset="2" id="homeInput">
            <el-select v-model="cancer" @change="cancerSelectChange" placeholder="请选择">
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
                  :disabled="dataisrenew(item.value)"
                ></el-option>
              </el-option-group>
            </el-select>
          </el-col>
        </el-row>
      </el-row>
    </el-card>
    <div>
      <el-card class="box-card-heatmap">
        <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="tigTab">
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
              ref="celltypeRef"
              :cancer="cancer" 
              :gloclu="gloClu" 
              :is="celltypeVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Differential Expression Analysis" name="scdiffexp">
            <component 
              ref="diffexpRef" 
              :cancer="cancer"
              :gloclu="gloClu"
              tabactiveName="cluster"
              :is="diffexpVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Pathway Analysis" name="scpathway">
            <component 
              ref="scpathwayRef" 
              :cancer="cancer"
              :gloclu="gloClu"
              :vsType="vsType"
              :is="scpathwayVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Co-expression Analysis" name="coexp">
            <component 
              ref="coexpRef" 
              :CancerType="cancer"
              :gloCluoptions="gloCluoptions"
              :is="coexpVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Trajectory Analysis" name="evolution">
            <component
              ref="evolutionRef"
              :cancer="cancer"
              :gloCluoptions="gloCluoptions"
              :is="evolutionVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Cross Talk" name="crosstalk">
            <component 
            :is="crosstalkVue" 
            :cancer="cancer"
            :gloCluoptions="gloCluoptions"
            ref="crosstalkRef"></component>
          </el-tab-pane>
        </el-tabs>
      </el-card>
    </div>
  </div>
</template>

<script>
import tigoverview from './overview.vue'
import tigcoexp from './coExp.vue'
import tigdiffexp from './diffExp.vue'
import tigcelltype from './celltype.vue'
import tigcrosstalk from './crosstalk.vue'
import tigevolution from './evolution.vue'
import tigpathway from './scpathway.vue'
      
import selectCancerIcon from './selectCancerIcon.vue'

export default {
  components: {
    selectCancerIcon,
  },
  data() {
    return {
      IconBladder: require("../../assets/Icons/Bladder.png"),
      IconBlood: require("../../assets/Icons/Blood.png"),
      IconBreast: require("../../assets/Icons/Breast.png"),
      IconColorectum: require("../../assets/Icons/Colorectum.png"),
      IconEye: require("../../assets/Icons/Eye.png"),
      IconHeadNeck: require("../../assets/Icons/HeadNeck.png"),
      IconKidney: require("../../assets/Icons/Kidney.png"),
      IconLiver: require("../../assets/Icons/Liver.png"),
      IconLung: require("../../assets/Icons/Lung.png"),
      IconNasopharyngeal: require("../../assets/Icons/Nasopharyngeal.png"),
      IconOvarian: require("../../assets/Icons/Ovarian.png"),
      IconPancreas: require("../../assets/Icons/Pancreas.png"),
      IconSkin: require("../../assets/Icons/Skin.png"),
      IconStomach: require("../../assets/Icons/Stomach.png"),
      IconUterine: require("../../assets/Icons/Uterine.png"),
      carouselShow: false,
      activeName: "overview",
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
      gene: "ERBB2",
      genelist: "",
      cancer: "CAC",
      gloClu: "",
      canceroptions: [],
      gloCluoptions: [],
      Signatures: "",
      vsType: "",
      scpathwayVue: "",
      datasetrenewed: ["CAC","BC","BCC","MPAL","CRC1","BTCC","UM","CRC2","UCEC","BC1","NSCLC","OV","MCC","HCC","PDAC","NSCLC6","NSCLC1","NSCLC3","CCRCC","TNBC","ICC","NSCLC4","HNSC"],
    };
  },

  created() {
    this.getcancer();
  },
  mounted() {
    this.getgloClu();
  },

  methods: {
    getcancer() {
      this.$http.get("/tiger/singlecelldataset.json").then((res) => {
        // console.log(res.data)
        this.canceroptions = res.data;
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
            type: "homescinfo",
          },
        })
        .then((res) => {
          this.gloCluoptions = res.data.list;
          this.overviewVue = tigoverview;
          this.activeName = "overview";
          this.$refs.overviewRef.clickPlot(); 
          // this.$refs.coexpRef.CancerTypeSelectChange();
        });
    },
    handleClick(tab) {
      this.checkVue(tab.name);
    },
    checkVue(name) {
      switch (name) {
        case "overview":
          this.overviewVue = tigoverview;
          break;
        case "celltype":
          this.celltypeVue = tigcelltype;
          this.$refs.celltypeRef.plot();
          break;
        case "scdiffexp":
          this.diffexpVue = tigdiffexp;
          this.$refs.diffexpRef.plot();
          this.vsType = this.$refs.diffexpRef.getvsType();
          break;
        case "scpathway":
          this.scpathwayVue = tigpathway;
          this.$refs.scpathwayRef.plot();
          break;
        case "coexp":
          this.coexpVue = tigcoexp;
          break;
        case "crosstalk":
          this.crosstalkVue = tigcrosstalk;
          this.$refs.crosstalkRef.plot();
          break;
        case "evolution":
          this.evolutionVue = tigevolution;
          break;
      }
    },
    dataisrenew(datasetid){
      // console.log(datasetid)
      for(const reneweddata of this.datasetrenewed){
        // console.log(reneweddata)
        if(datasetid === reneweddata){
          return false
        }
      }
      return true
    }
  },
};
</script>

<style>

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
#tab-overview, 
#tab-celltype,
#tab-scdiffexp,
#tab-scpathway,
#tab-coexp,
#tab-crosstalk,
#tab-evolution{
    font-size: 18px;
    height: 55px;
    padding: 10px;
    font-weight: bold !important;
}
</style>