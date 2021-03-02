<template>
  <div class="outside">
    <el-card id="readmeCard">
      <el-row id="readme">Readme:</el-row>
      1. This module provides users with
      <span class="readmeEmp">plentiful scRNA-seq analysis</span> functions in
      six tabs including the <span class="readmeEmp">Overview</span>,
      <span class="readmeEmp">Cell Type Marker</span>,
      <span class="readmeEmp">Differential Expression Analysis</span>,
      <span class="readmeEmp">Correlation Analysis</span>,
      <span class="readmeEmp">Trajectory Analysis</span> and
      <span class="readmeEmp">Cell-Cell Communication</span> tabs.<br />
      2. In the <span class="readmeEmp">interactive heatmap</span>, users could
      use a selection box provided to quickly
      <span class="readmeEmp">locate main lineage cell types</span> of interest,
      and a text box is provided to allow users to
      <span class="readmeEmp">search genes</span> of interest.<br />
      3. Moreover, users can click tab/cell of a table for detail information,
      such as UMAP plots and boxplot used to visualize the clustering
      results of selected main lineage cells.
    </el-card>
    <el-card id="scimmucard">
      <el-row id="scImmuInput">
        <el-col>
          <el-collapse v-model="datasetcoll">
            <el-collapse-item name="datasetsel">
              <span class="collapse-title" slot="title">Select A Dataset</span>
              <el-row class="detail1" gutter="20" justify="center">
                <el-col
                  span="8"
                  push="0"
                  v-for="cancertype in cancertypearr"
                  :key="cancertype.icon"
                >
                  <select-cancer-icon
                    v-on:datasetid="getdatasetid"
                    :imgurl="cancertype.icon"
                    :IconName="cancertype.name"
                    :datasets="cancertype.datasetid.split('_')"
                    :datasetsname="cancertype.datasetname.split('_')"
                  >
                  </select-cancer-icon>
                </el-col>
              </el-row>
            </el-collapse-item>
          </el-collapse>
        </el-col>
      </el-row>
    </el-card>
    <div>
      <el-card id="tabdetail" class="box-card-heatmap">
        <el-tabs
          v-model="activeName"
          type="card"
          @tab-click="handleClick"
          stretch
          class="tigTab"
        >
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
              :gloCluoptions="gloCluoptions"
              :is="celltypeVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane
            label="Differential Expression Analysis"
            name="scdiffexp"
          >
            <component
              ref="diffexpRef"
              :cancer="cancer"
              :gloclu="gloClu"
              :gloCluoptions="gloCluoptions"
              tabactiveName="cluster"
              :is="diffexpVue"
            ></component>
          </el-tab-pane>
          <!-- <el-tab-pane label="Pathway Analysis" name="scpathway">
            <component 
              ref="scpathwayRef" 
              :cancer="cancer"
              :gloclu="gloClu"
              :vsType="vsType"
              :is="scpathwayVue"
            ></component>
          </el-tab-pane> -->
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
          <el-tab-pane label="Cell-Cell Communication" name="crosstalk">
            <component
              :is="crosstalkVue"
              :cancer="cancer"
              :gloCluoptions="gloCluoptions"
              ref="crosstalkRef"
            ></component>
          </el-tab-pane>
        </el-tabs>
      </el-card>
    </div>
  </div>
</template>

<script>
import tigoverview from "./overview.vue";
import tigcoexp from "./coExp.vue";
import tigdiffexp from "./diffExp.vue";
import tigcelltype from "./celltype.vue";
import tigcrosstalk from "./crosstalk.vue";
import tigevolution from "./evolution.vue";
import tigpathway from "./scpathway.vue";
import selectCancerIcon from "./selectCancerIcon.vue";
import { toTargetbyid } from "../../../static/js/utils.js";

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
      gloCluoptions: [
        { GlobalCluster: "All" },
        { GlobalCluster: "Tcell" },
        { GlobalCluster: "CD4" },
        { GlobalCluster: "CD8" },
        { GlobalCluster: "Bcell" },
        { GlobalCluster: "Myeloid" },
      ],
      Signatures: "",
      vsType: "",
      scpathwayVue: "",
      datasetcoll: "datasetsel",
      cancertypearr: [
        {
          name: "Bladder",
          datasetid: "BTCC_BTCC1",
          datasetname:
            "BTCC | Oh DY, et al. Cell. 2020_BTCC | Chen, Z., Nat Commun 2020",
          PMID: "32497499",
          icon: require("../../assets/Icons/Bladder.png"),
        },
        {
          name: "Blood",
          datasetid: "MPAL",
          datasetname: "MPAL | Granja JM, et al. Nat Biotechnol. 2019",
          PMID: "31792411",
          icon: require("../../assets/Icons/Blood.png"),
        },
        {
          name: "Breast",
          datasetid: "BC_BC1_TNBC",
          datasetname:
            "BC | Qian J, et al. Cell Res. 2020_BC | Elham A, et al. Cell. 2018 Aug 23_TNBC | Savas P, et al. Nat Med. 2018 Jul",
          PMID: "32561859_29961579_29942092",
          icon: require("../../assets/Icons/Breast.png"),
        },
        {
          name: "Colorectum",
          datasetid: "CAC_CRC1_CRC2",
          datasetname:
            "CRC | Wu TD, et al. Nature. 2020_CRC | Lee HO, et al. Nat Genet. 2020_CRC | Qian J, et al. Cell Res. 2020 Jun 20",
          PMID: "32103181_32451460_32561858",
          icon: require("../../assets/Icons/Colorectum.png"),
        },
        {
          name: "Eye",
          datasetid: "UM",
          datasetname: "UM | Durante MA, et al. Nat Commun. 2020",
          PMID: "31980621",
          icon: require("../../assets/Icons/Eye.png"),
        },
        {
          name: "HeadNeck",
          datasetid: "HNSC",
          datasetname: "HNSC | Cillo AR, et al. Immunity. 2020",
          PMID: "31924475",
          icon: require("../../assets/Icons/HeadNeck.png"),
        },
        {
          name: "Kidney",
          datasetid: "CCRCC",
          datasetname:
            "CCRCC | Wu TD, et al. Nature. 2020_MUC | Yuen, K.C., et al. Nat Med 2020",
          PMID: "32103181",
          icon: require("../../assets/Icons/Kidney.png"),
        },
        {
          name: "Liver",
          datasetid: "HCC_ICC",
          datasetname:
            "HCC | Ma L, et al. Cancer Cell. 2019_ICC | Zhang M, et al. J Hepatol. 2020 Jun 5",
          PMID: "31588021_32505533",
          icon: require("../../assets/Icons/Liver.png"),
        },
        {
          name: "Lung",
          datasetid: "NSCLC_NSCLC1_NSCLC3_NSCLC4_NSCLC5_NSCLC6_NSCLC7",
          datasetname:
            "NSCLC | Lambrechts D, et al. Nat Med. 2018_NSCLC | Wu TD, et al. Nature. 2020_NSCLC | Zilionis R, et al. Immunity. 2019_NSCLC | Guo X, et al. Nat Med. 2018_NSCLC | Kim, N., et al. Nat Commu 2020_NSCLC | Ashley Maynard, et al. Cell. 2020_NSCLC | Laughney, A.M., Nat Med 2020",
          PMID: "29988129_32103181_30979687_29942094_32686767_32822576",
          icon: require("../../assets/Icons/Lung.png"),
        },
        {
          name: "Nasopharyngeal",
          datasetid: "NPC",
          datasetname: "NPC | hen YP, et al. Cell Res. 2020",
          PMID: "32686767",
          icon: require("../../assets/Icons/Nasopharyngeal.png"),
        },
        {
          name: "Ovarian",
          datasetid: "OV",
          datasetname: "OV | Qian J, et al. Cell Res. 2020",
          PMID: "32561858",
          icon: require("../../assets/Icons/Ovarian.png"),
        },
        {
          name: "Pancreas",
          datasetid: "PDAC_PDAC2",
          datasetname:
            "PDAC | Peng J, et al. Cell Res. 2019_PDAC | Steele, Nina G, et al. Nat Cancer. 2020",
          PMID: "31273297",
          icon: require("../../assets/Icons/Pancreas.png"),
        },
        {
          name: "Skin",
          datasetid: "BCC_MCC_SKCM1_SKCM3",
          datasetname:
            "BCC | Yost KE, et al. Nat Med. 2019_MCC | Paulson KG, et al. Nat Commun. 2018_SKCM | Sade-Feldman M, et al. Cell. 2018_SKCM | Slyper, M., Nat Med 2020",
          PMID: "31359002_30250229_30388456",
          icon: require("../../assets/Icons/Skin.png"),
        },
        {
          name: "Stomach",
          datasetid: "STAD",
          datasetname: "STAD | Zhang P, et al. Cell Rep. 2019",
          PMID: "31067475",
          icon: require("../../assets/Icons/Stomach.png"),
        },
        {
          name: "Uterine",
          datasetid: "UCEC_MUC",
          datasetname:
            "UCEC | Wu TD, et al. Nature. 2020_MUC | Yuen, K.C., et al. Nat Med 2020",
          PMID: "32103181",
          icon: require("../../assets/Icons/Uterine.png"),
        },
        {
          name: "Prostate",
          datasetid: "PRAD1_PRAD2_CRPC_CRPC2", //
          datasetname:
            "PRAD | Chen, S., et al. Nat Cell Biol 2021_PRAD | Ma X, et al. Mol Cancer 2020_CRPC | Dong, B., et al Commun Biol 2020_CRPC | Chen, S., et al. Nat Cell Biol 2021",
          icon: require("../../assets/Icons/Prostate.png"),
        },
        {
          name: "Osteosarcoma",
          datasetid: "OS",
          datasetname: "OS | Zhou, Y., et al Nat Commun. 2020",
          icon: require("../../assets/Icons/Bone.png"),
        },
        {
          name: "Esophagus",
          datasetid: "ESCC",
          datasetname: "ESCC | Zheng, Y., Nat Commun 2020",
          icon: require("../../assets/Icons/Esophagus.png"),
        },
      ],
    };
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
    getdatasetid(childid) {
      // console.log(childid)
      this.datasetcoll = "";
      this.cancer = childid;
      this.cancerSelectChange();
      toTargetbyid("#tabdetail");
      // toTarget('#tabdetail')
    },
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
#tab-evolution {
  font-size: 18px;
  height: 55px;
  padding: 10px;
  font-weight: bold !important;
}
.collapse-title {
  flex: 1 0 90%;
  order: 1;
  color: rgb(20, 146, 140);
  font-size: 18px;
}
.el-collapse-item__header {
  flex: 1 0 auto;
  order: -1;
}
</style>