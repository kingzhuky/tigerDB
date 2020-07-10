<template>
  <div class="outside">
    <el-card class="serachpage" id="helppage">
      <div class="main_con" id="1" ref="userinfo1">
        <h1 class="subtitle">Introduction to TIGER</h1>
        <el-divider></el-divider>
        <el-row>
          <el-col :span="12">
            <p>TIGER, a web-accessible and comprehensive open resource for providing the gene expression landscape of tumor immunology. Currently, TIGER contains bulk transcriptome data for 1022 samples with immunotherapy clinical outcome and 11,060 samples from TCGA, and single cell transcriptome data for 66,366 immune cells of 43 samples with immunotherapy clinical outcome and 485,168 immune cells of 151 samples without immunotherapy clinical outcome. Besides, we also collected eight CRISPR and two shRNA screening data from studies identifying genes responsible of anticancer immune response. Moreover, we collected 63 gene signatures that could be potentially used to predict the immunotherapy response from public literature.</p>
          </el-col>
          <el-col :span="10" :offset="2">
            <img alt="help" v-lazy="home" />
          </el-col>
        </el-row>
      </div>

      <!-- <div class="main_con" id="2" ref="userinfo2">
        <h1 class="subtitle">Data sources</h1>
        <el-divider></el-divider>
        <p>
          At present, m6A2Target absorbs WERs knockdown or overexpression experiment conclusion from all published literature, and WERs related high-throughput sequence data and mass spectrometry in GEO database. Differential expression analysis, differential methylation analysis, differential translation analysis, CLIP data analysis, RIP data analysis and the like were all integrated to explore the WERs target genes.
          Multiple data and statistical diagrams are embedded in the web server for users to obtain the target gene information.
        </p>

        <h2 class="sub">1) Data sources</h2>
        <div class="htable">
          <el-table :data="tableData" stripe border style="width: 100%">
            <el-table-column prop="name" label="Name"></el-table-column>
            <el-table-column label="Description">
              <template slot-scope="scope">
                <a v-html="scope.row.source"></a>
              </template>
            </el-table-column>

            <el-table-column label="URL">
              <template slot-scope="scope">
                <a v-html="scope.row.url"></a>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div> -->

      <div class="main_con" id="4" ref="userinfo4">
        <h1 class="subtitle">Usage of TIGER</h1>
        <el-divider></el-divider>
        <p>TIGER is composed of four major modules, including Immune Response, Immune Signature, Single-cell Immunity and Immune Screening with a Quick Search module.</p>
      </div>
      <h2>Quick start</h2>
      <p>When users enter the webpage, they can see a quick search bar at the bottom of the page. Users can search for the gene symbol of interest to obtain results with significant differences in all data sets, such as the difference between tumor tissues and normal tissues in different cell types, the difference between immunotherapy response and non-response samples.</p>
      <div align="center">
        <img alt="help1" v-lazy="help1" />
      </div>

      <h2 class="sub">Module of Immune Response</h2>
      <p>Users can enter the Immune Response module to visually view the expression differences of all genes in the immunotherapy response and non-response groups, including different immunotherapy methods, and even be able to view the gender differences in immunotherapy response.</p>
      <p>The module is divided into three sub-modules, which are Differential Expression Analysis, Survival Analysis, Signature analysis.</p>
      <div align="center">
        <img alt="help2" v-lazy="help2" />
      </div>

      <h3 class="sub">Differential Expression Analysis of Immune Response</h3>
      <p>Users can directly switch between the results of differential expression analysis of immunotherapy Response and Non-response, Pre-Therapy and Post-Therapy. In additions, Users can visually view the differences in the expression of all genes in the Immune Response, including different immunotherapy methods, and even better, can view the gender differences in immunotherapy responses. The user can directly locate the corresponding gene through the search bar, and can jump to the data set of different cancer types through the drop-down bar on the left.</p>
      <div align="center">
        <img alt="help3" v-lazy="help3" />
      </div>
      <p>TIGER provides a user-friendly interactive heat map. By clicking on the differential gene, you can get a specific box plot and violin plot in the data set, and you can see the difference between this gene and other immune Signatures in predicting the response to immunotherapy.</p>
      <div align="center">
        <img alt="help4" v-lazy="help4" />
      </div>

      <h3 class="sub">Survival Analysis of Immune Response</h3>
      <p>Users can directly see the relationship between all gene expressions in different data sets and survival through the heat map. In the data set, the sample will be subdivided according to the sample's treatment information and gender differences. In addition, red represents poor prognosis and blue represents good prognosis. By clicking on the color square, you can live the Km survival curve, and the forest map of cox single factor regression.</p>
      <div align="center">
        <img alt="help3" v-lazy="help5" />
      </div>
      <h3 class="sub">Signature Analysis of Immune Response</h3>
      <p>Users can customize the signature or choose whether the immune signature analysis in the article will affect the prognosis of immunotherapy. In this way, find the signature or gene that is potentially beneficial to the prognosis.</p>

      <h2 class="sub">Module of Immune Signature</h2>
      <p>By inputting a single gene or gene set as a signature, the user performs correlation analysis with known signatures in pan-cancer species. TIGER provides an interactive heat map of correlation coefficients. You can see more detailed correlation results with user-defined signatures by clicking on different immune signatures. Carry out pan-cancer association analysis in the TCGA data to find genes or gene sets that are more relevant to the immune Signature in different cancers, and combine them with the results of the Immune Response module to be able to identify more cancers Find genes or gene sets related to immunotherapy, and help research and analysis of immunotherapy prognosis</p>
      <div align="center">
        <img alt="help2" v-lazy="help6" />
      </div>

      <h2 class="sub">Module of Single-cell Immunity</h2>
      <p>Single-cell sequencing results in cancer show differences in different immune cell types. At the single-cell level, further analysis of genes analyzed in immunotherapy and immune signatures provides more details, including the distribution of genes in different immune cell types (tSNE), and differences in cell types between immunotherapy response and non-response (boxplot)</p>
      <div align="center">
        <img alt="help2" v-lazy="help7" />
      </div>

      <p>Interactive heat map similar to bulk RNA-seq, you can get detailed information by clicking, including differential expression of genes, distribution of genes in evolution map, etc.</p>
      <div align="center">
        <img alt="help2" v-lazy="help8" />
      </div>
      <p>By entering a gene, TIGER will perform gene co-expression analysis at the single cell level in the selected cancer species and cell subsets. Through the correlation between gene expressions, find the co-expression relationship between different cell types, so as to find out the co-expression relationship of the gene of interest between cells</p>
      <div align="center">
        <img alt="help2" v-lazy="help9" />
      </div>

      <h2 class="sub">Module of Immune Screening</h2>
      <p>TIGER integrates immune-related CRISPR Screen and shRNA screen data, provides interactive heat maps, analyzes immunity at the experimental level, and finds genes related to immunity in the immune-related screen data. Click to get the corresponding screen data information and gene-related drug information</p>
      <div align="center">
        <img alt="help2" v-lazy="help10" />
      </div>
    </el-card>
    <goTop></goTop>
  </div>
</template>


<script>
import goTop from "./public/goTop";

export default {
  data() {
    return {
      scrollTop2: "",
      fix: "fixed",
      toCity: "Help",
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
      help10: require("../assets/help10.png")
    };
  },
  methods: {},
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
</style>
