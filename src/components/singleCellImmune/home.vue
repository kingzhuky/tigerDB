<template>
  <div class="outside">
    <el-card id="scimmucard">
      <el-row id="scImmuInput">

        <el-row>
          <el-col :span="20" :offset="2">
            <p class="scImmuTitle">Select A Dataset</p>
          </el-col>
        </el-row>
        <br/>
        <el-row gutter="20" justify="center">
          <el-col span="cancertype.name === 'Lung' ? 10：5" push="2" v-for="cancertype in cancertypearr" :key="cancertype.icon">
            <select-cancer-icon
              v-on:datasetid="getdatasetid"
              :imgurl="cancertype.icon"
              :IconName="cancertype.name"
              :datasets="cancertype.datasetid.split('_')"
              :datasetsname="cancertype.datasetname.split('_')">
            </select-cancer-icon>
          </el-col>
        </el-row>

        <!-- <el-row>
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
        </el-row> -->
      </el-row>
    </el-card>
    <div>
      <el-card id="tabdetail" class="box-card-heatmap">
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
import toTarget from "../public/goTop";
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
      cancertypearr:[
  {
    "name": "Bladder",
    "datasetid": "BTCC",
    "cancertype": "Bladder Transitional Cell Carcinoma (BTCC)",
    "datasetname": "Oh DY, et al. Cell. 2020 Jun 25",
    "PMID": "32497499",
    "icon": require("../../assets/Icons/Bladder.png")
  },
  {
    "name": "Blood",
    "datasetid": "MPAL",
    "cancertype": "Mixed phenotype acute leukemia (MPAL)",
    "datasetname": "Granja JM, et al. Nat Biotechnol. 2019 Dec",
    "PMID": "31792411",
    "icon": require("../../assets/Icons/Blood.png")
  },
  {
    "name": "Breast",
    "datasetid": "BC_BC1_TNBC",
    "cancertype": "Breast cancer (BC)_Breast cancer (BC)_Triple-negative breast cancer (TNBC)",
    "datasetname": "Qian J, et al. Cell Res. 2020 Jun 21_Elham A, et al. Cell. 2018 Aug 23_Savas P, et al. Nat Med. 2018 Jul",
    "PMID": "32561859_29961579_29942092",
    "icon": require("../../assets/Icons/Breast.png")
  },
  {
    "name": "Colorectum",
    "datasetid": "CAC_CRC1_CRC2",
    "cancertype": "Colorectal cancer (CRC)_Colorectal cancer (CRC)_Colorectal cancer (CRC)",
    "datasetname": "Wu TD, et al. Nature. 2020 Mar_Lee HO, et al. Nat Genet. 2020 May 25_Qian J, et al. Cell Res. 2020 Jun 20",
    "PMID": "32103181_32451460_32561858",
    "icon": require("../../assets/Icons/Colorectum.png")
  },
  {
    "name": "Eye",
    "datasetid": "UM",
    "cancertype": "Uveal Melanoma (UM)",
    "datasetname": "Durante MA, et al. Nat Commun. 2020 Jan 24",
    "PMID": "31980621",
    "icon": require("../../assets/Icons/Eye.png")
  },
  {
    "name": "HeadNeck",
    "datasetid": "HNSC",
    "cancertype": "Head-Neck Squamous Cell Carcinoma (HNSC)",
    "datasetname": "Cillo AR, et al. Immunity. 2020 Jan 14",
    "PMID": "31924475",
    "icon": require("../../assets/Icons/HeadNeck.png")
  },
  {
    "name": "Kidney",
    "datasetid": "CCRCC",
    "cancertype": "Clear cell renal cell carcinoma (CCRCC)",
    "datasetname": "Wu TD, et al. Nature. 2020 Mar",
    "PMID": "32103181",
    "icon": require("../../assets/Icons/Kidney.png")
  },
  {
    "name": "Liver",
    "datasetid": "HCC_ICC",
    "cancertype": "Hepatocellular carcinoma (HCC)_Intrahepatic cholangiocarcinoma (ICC)",
    "datasetname": "Ma L, et al. Cancer Cell. 2019 Oct 14_Zhang M, et al. J Hepatol. 2020 Jun 5",
    "PMID": "31588021_32505533",
    "icon": require("../../assets/Icons/Liver.png")
  },
  {
    "name": "Lung",
    "datasetid": "NSCLC_NSCLC1_NSCLC3_NSCLC4_NSCLC5_NSCLC6",
    "cancertype": "Non-small-cell lung carcinoma (NSCLC)_Non-small-cell lung carcinoma (NSCLC)_Non-small-cell lung carcinoma (NSCLC)_Non-small-cell lung carcinoma (NSCLC)_Non-small-cell lung carcinoma (NSCLC)_Non-small-cell lung carcinoma (NSCLC)",
    "datasetname": "Lambrechts D, et al. Nat Med. 2018 Aug_Wu TD, et al. Nature. 2020 Mar_Zilionis R, et al. Immunity. 2019 May 21_Guo X, et al. Nat Med. 2018 Jul_Kim, N., et al. Nat Commu 2020 May 8_Ashley Maynard, et al. Cell. 2020 Sep 3",
    "PMID": "29988129_32103181_30979687_29942094_32686767_32822576",
    "icon": require("../../assets/Icons/Lung.png")
  },
  {
    "name": "Nasopharyngeal",
    "datasetid": "NPC",
    "cancertype": "Nasopharyngeal carcinoma (NPC)",
    "datasetname": "hen YP, et al. Cell Res. 2020 Jul",
    "PMID": "32686767",
    "icon": require("../../assets/Icons/Nasopharyngeal.png")
  },
  {
    "name": "Ovarian",
    "datasetid": "OV",
    "cancertype": "Ovarian cancer (OV)",
    "datasetname": "Qian J, et al. Cell Res. 2020 Jun 19",
    "PMID": "32561858",
    "icon": require("../../assets/Icons/Ovarian.png")
  },
  {
    "name": "Pancreas",
    "datasetid": "PDAC",
    "cancertype": "Pancreatic ductal adenocarcinoma (PDAC)",
    "datasetname": "Peng J, et al. Cell Res. 2019 Sep",
    "PMID": "31273297",
    "icon": require("../../assets/Icons/Pancreas.png")
  },
  {
    "name": "Skin",
    "datasetid": "BCC_MCC_SKCM1",
    "cancertype": "Basal cell carcinoma (BCC)_Merkel cell carcinoma (MCC)_Skin cutaneous melanoma (SKCM)",
    "datasetname": "Yost KE, et al. Nat Med. 2019 Aug_Paulson KG, et al. Nat Commun. 2018 Sep 24_Sade-Feldman M, et al. Cell. 2018 Nov 1",
    "PMID": "31359002_30250229_30388456",
    "icon": require("../../assets/Icons/Skin.png")
  },
  {
    "name": "Stomach",
    "datasetid": "STAD",
    "cancertype": "Stomach adenocarcinoma (STAD)",
    "datasetname": "Zhang P, et al. Cell Rep. 2019 May 7",
    "PMID": "31067475",
    "icon": require("../../assets/Icons/Stomach.png")
  },
  {
    "name": "Uterine",
    "datasetid": "UCEC",
    "cancertype": "Uterine Corpus Endometrial Carcinoma (UCEC)",
    "datasetname": "Wu TD, et al. Nature. 2020 Mar",
    "PMID": "32103181",
    "icon": require("../../assets/Icons/Uterine.png")
  },
  {
    "name": "Prostate",
    "datasetid": "PRAD1_PRAD2",
    "datasetname": "PRAD1_PRAD2",
    "icon": require("../../assets/Icons/Uterine.png")
  }
]
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
    toTarget2() {
      var PageId = document.querySelector('#tabdetail')
      console.log(PageId.offsetTop)
      window.scrollTo({
        'top': PageId.offsetTop,
        'behavior': 'smooth'
      })
    },
    getdatasetid: function(childid){
      console.log(childid)
      this.cancer = childid
      this.cancerSelectChange()
      this.toTarget2()
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