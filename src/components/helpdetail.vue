<template>
  <div class="outside">
    <div v-show="searchshow">
      <h2>Quick Search</h2>
      <p>When users enter the website, they can see a quick search bar at the middle of the page.
        <br/>
      </p>
      <div align="center">
        <img class="helpimg-main" alt="helphome" v-lazy="helphome" />
      </div>
      <p>Users can search for the gene symbol of interest to obtain results with significant differences in all data sets, such as the difference between tumor tissues and normal tissues in different cell types, the difference between immunotherapy response and non-response samples.</p>
      <div align="center">
        <img alt="help1" v-lazy="help1" />
      </div>
      <p>TIGER will comprehensively analyze the functions of the four modules (Immunotherapy Response, Immunotherapy Response Signature, Singcell Immunity, Immune Screening) to obtain an integrated result.<br/>
      Firstly, There is a summary of Gene interested in, which including Gene Information and Pathway Information.</p>
      <div align="center">
        <img class="helpimg-detail" alt="search1_1" v-lazy="search1_1" />
      </div>
      <p>Secondly, TIGER will show the Differential Expression Analysis and Survival Analysis with clinical info. The scatter plot and the specific difference result table of each dataset will be analyzed and displayed.</p>
      <div align="center">
        <img class="helpimg-detail" alt="search2_1" v-lazy="search2_1" />
        <img class="helpimg-detail" alt="search2_2" v-lazy="search2_2" />
        <img class="helpimg-detail" alt="search2_3" v-lazy="search2_3" />
      </div>
      <p>Gene-related CRISPER Screen and SiRNA Screen information will be displayed in the form of a table, and you can get the dataset related information by clicking on the row of the table.</p>
      <div align="center">
        <img class="helpimg-detail" alt="search4_1" v-lazy="search4_1" />
      </div>
      <p>Through the correlation analysis of the gene in Pan-cancer, you can know which Immunotherapy Response Signature of the gene is more related, and you can see the specific correlation scatter diagram by clicking the cell of table.</p>
      <div align="center">
        <img class="helpimg-detail" alt="search5_1" v-lazy="search5_1" />
      </div>
    </div>

    <div v-show="responseshow">
      <h2 class="sub">Module of Immunotherapy Response</h2>
      <p>Users can enter the Immunotherapy Response module to visually view the expression differences of all genes in the immunotherapy response and non-response groups, including different immunotherapy methods, and even be able to view the gender differences in immunotherapy response.</p>
      <p>The module is divided into three sub-modules, which are Differential Expression Analysis, Survival Analysis, Signature analysis.</p>
      <div align="center">
        <img alt="help2" v-lazy="help2" />
      </div>

      <h3 class="sub">Differential Expression Analysis of Immunotherapy Response</h3>
      <p>Users can directly switch between the results of differential expression analysis of immunotherapy Response and Non-response, Pre-Therapy and Post-Therapy. In additions, Users can visually view the differences in the expression of all genes in the Immunotherapy Response, including different immunotherapy methods, and even better, can view the gender differences in immunotherapy responses. The user can directly locate the corresponding gene through the search bar, and can jump to the data set of different cancer types through the drop-down bar on the left.</p>
      <div align="center">
        <img alt="help3" v-lazy="help3" />
      </div>
      <p>TIGER provides a user-friendly interactive heat map. By clicking on the differential gene, you can get a specific box plot and violin plot in the data set, and you can see the difference between this gene and other immune Signatures in predicting the response to immunotherapy.</p>
      <div align="center">
        <img alt="help4" v-lazy="help4" />
      </div>

      <h3 class="sub">Survival Analysis of Immunotherapy Response</h3>
      <p>Users can directly see the relationship between all gene expressions in different data sets and survival through the heat map. In the data set, the sample will be subdivided according to the sample's treatment information and gender differences. In addition, red represents poor prognosis and blue represents good prognosis. By clicking on the color square, you can live the Km survival curve, and the forest map of cox single factor regression.</p>
      <div align="center">
        <img class="helpimg-detail" alt="help3" v-lazy="help5" />
      </div>
      <h3 class="sub">Geneset Query</h3>
      <p>Users can customize the signature or choose whether the immune signature analysis in the article will affect the prognosis of immunotherapy. In this way, find the signature or gene that is potentially beneficial to the prognosis.</p>
      <div align="center">
        <img class="helpimg-detail" alt="response3_1" v-lazy="response3_1" />
      </div>
    </div>

    <div v-show="signatureshow">
      <h2 class="sub">Module of Immunotherapy Response Signature</h2>
      
      <h3 class="sub">Overview</h3>
      <p>Use the Overview table of Immunotherapy Response Signature to show the degree of correlation between each Immunotherapy Response Signature and immune response (AUC is obtained from the analysis of all immune response data collected).</p>
      <div align="center">
        <img class="helpimg-detail" alt="signature1_1" v-lazy="signature1_1" />
      </div>
      <p>Click on the detail button in the table, and TIGER will display the related information of changing Immunotherapy Response Signature, as well as the Differential Signature Score Analysis in immune response data and Tumor/Normal expression data.</p>
      <div align="center">
         <img class="helpimg-detail" alt="signature1_2" v-lazy="signature1_2" />
      </div>
      
      <h3 class="sub">Custom Analysis</h3>
      <p>Through Immunotherapy Response Signature analysis of the expression matrix and sample information provided by the user, the correlation between the sample and the Immunotherapy Response Signature is shown to be related to the immune response of the tumor.</p>
      <div align="center">
         <img class="helpimg-detail" alt="signature2_1" v-lazy="signature2_1" />
      </div>
      <div align="center">
         <img class="helpimg-detail" alt="signature2_2" v-lazy="signature2_2" />
      </div>

      <h3 class="sub">Signature Correlation Analysis</h3>
      <p>By inputting a single gene or gene set as a signature, the user performs correlation analysis with known signatures in pan-cancer species. TIGER provides an interactive heat map of correlation coefficients. You can see more detailed correlation results with user-defined signatures by clicking on different immune signatures. Carry out pan-cancer association analysis in the TCGA data to find genes or gene sets that are more relevant to the immune Signature in different cancers, and combine them with the results of the Immunotherapy Response module to be able to identify more cancers Find genes or gene sets related to immunotherapy, and help research and analysis of immunotherapy prognosis</p>
      <div align="center">
         <img class="helpimg-detail" alt="signature3_1" v-lazy="signature3_1" />
      </div>
    </div>

    <div v-show="singcellshow">
      <h2 class="sub">Module of Single-cell Immunity</h2>
      <h3 class="sub">Overview</h3>
      <p>Single-cell sequencing results in cancer show differences in different immune cell types. At the single-cell level, further analysis of genes analyzed in immunotherapy and immune signatures provides more details, including the distribution of genes in different immune cell types (tSNE), and differences in cell types between immunotherapy response and non-response (boxplot)</p>
      <div align="center">
         <img class="helpimg-detail" alt="singcell1_1" v-lazy="singcell1_1" />
      </div>

      <h3 class="sub">Cell Marker / Differential Expression / Pathway Analysis</h3>
      <p>Interactive heat map similar to bulk RNA-seq, you can get detailed information by clicking, including differential expression of genes, distribution of genes in evolution map, etc.</p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell2_1" v-lazy="singcell2_1" />
        <img class="helpimg-detail" alt="singcell3_1" v-lazy="singcell3_1" />
        <img class="helpimg-detail" alt="singcelln4" v-lazy="singcelln4" />
      </div>

      <h3 class="sub">Co-expression Analysis</h3>
      <p>By entering a gene, TIGER will perform gene co-expression analysis at the single cell level in the selected cancer species and cell subsets. Through the correlation between gene expressions, find the co-expression relationship between different cell types, so as to find out the co-expression relationship of the gene of interest between cells</p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell4_1" v-lazy="singcell4_1" />
      </div>

      <h3 class="sub">Trajectory Analysis</h3>
      <p>By entering a gene, TIGER will perform gene co-expression analysis at the single cell level in the selected cancer species and cell subsets. Through the correlation between gene expressions, find the co-expression relationship between different cell types, so as to find out the co-expression relationship of the gene of interest between cells</p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell5_1" v-lazy="singcell5_1" />
      </div>
    </div>

    <div v-show="screenshow">
      <h2 class="sub">Module of Immune Screening</h2>
      <p>TIGER integrates immune-related CRISPR Screen and shRNA screen data, provides interactive heat maps, analyzes immunity at the experimental level, and finds genes related to immunity in the immune-related screen data. Click to get the corresponding screen data information and gene-related drug information</p>
      <div align="center">
        <img alt="help2" v-lazy="help10" />
      </div>
    </div>
  </div>
</template>


<script>
import goTop from "./public/goTop";

export default {
   props: {
    tabname: String,
  },
  data() {
    return {
      home: require("../assets/home1.png"),
      help1: require("../assets/help1.png"),
      help2: require("../assets/help2.png"),
      help3: require("../assets/help3.png"),
      help4: require("../assets/help4.png"),
      help5: require("../assets/help5.png"),
      help6: require("../assets/help6.png"),
      help7: require("../assets/help7.png"),
      help8: require("../assets/help8.png"),
      help9: require("../assets/help9.png"),
      help10: require("../assets/help10.png"),
      helphome: require("../assets/help-home.png"),
      response3_1: require("../assets/response-3-1.png"),
      search1_1: require("../assets/search-1-1.png"),
      search1_2: require("../assets/search-1-2.png"),
      search2_1: require("../assets/search-2-1.png"),
      search2_2: require("../assets/search-2-2.png"),
      search2_3: require("../assets/search-2-3.png"),
      search4_1: require("../assets/search-4-1.png"),
      search5_1: require("../assets/search-5-1.png"),
      signature1_1: require("../assets/signature-1-1.png"),
      signature1_2: require("../assets/signature-1-2.png"),
      signature2_1: require("../assets/signature-2-1.png"),
      signature2_2: require("../assets/signature-2-2.png"),
      signature3_1: require("../assets/signature-3-1.png"),
      singcell1_1: require("../assets/singcell-1-1.png"),
      singcell2_1: require("../assets/singcell-2-1.png"),
      singcell3_1: require("../assets/singcell-3-1.png"),
      singcelln4: require("../assets/singcell-n4.png"),
      singcell4_1: require("../assets/singcell-4-1.png"),
      singcell5_1: require("../assets/singcell-5-1.png"),
      searchshow: false,
      responseshow: false,
      signatureshow: false,
      singcellshow: false,
      screenshow: false,
    };
  },
  methods: {
    resetshow(){
      this.searchshow = false;
      this.responseshow = false;
      this.signatureshow = false;
      this.singcellshow = false;
      this.singcellshow = false;
    },
    changeshow(tabname){
      this.resetshow();
      switch (tabname) {
        case "search":
          this.searchshow = true;
          break;
        case "response":
          this.responseshow = true;
          break;
        case "signature":
          this.signatureshow = true;
          break;
        case "singcell":
          this.singcellshow = true;
          break;
        case "screen":
          this.screenshow = true;
          break; 
        default:
          this.resetshow();
      }
    },
  },
  components: {
    goTop
  }
};
</script>

<style>
.father {
  text-align: center !important;
}
.help_p1 {
  width: 960px !important;
}
.main_con {
  text-align: justify;
  line-height: 30px;
}

.el-divider--horizontal {
  height: 2px !important;
}
.subtitle {
  padding-top: 20px;
  font-weight: bold;
  font-size: 30px;
}
#helppage p {
  font-size: 18px !important;
  margin-top: 10px !important;
  margin-bottom: 10px !important;
  color: #333 !important;
}

#helppage {
  border-radius: 15px !important;
  font-size: 16px !important;
  color: #333 !important;
}

.sub {
  font-size: 22px !important;
}

.bold {
  font-weight: bold;
}

h3 {
  color: rgb(119, 97, 97);
}
.helpimg-main{
  width: 80%;
}
.helpimg-detail{
  width:30%;
}
</style>
