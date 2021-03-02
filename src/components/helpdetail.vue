<template>
  <div class="outside">
    <div v-show="searchshow">
      <h2>Quick Search</h2>
      <p>
        When users enter the website, they can see a quick search bar at the
        middle of the page.
        <br />
      </p>
      <div align="center">
        <img class="helpimg-main" alt="helphome" v-lazy="helphome" />
      </div>
      <p>
        Users can search for the gene symbol of interest to obtain results with
        significant differences in all data sets, such as the difference between
        tumor tissues and normal tissues in different cell types, the difference
        between immunotherapy response and non-response samples.
      </p>
      <div align="center">
        <img alt="help1" v-lazy="help1" />
      </div>
      <p>
        TIGER will comprehensively analyze the functions of the four modules
        (<span class="readmeEmp"
          >Immunotherapy Response, Response Signature, Singcell Immunity, Immune
          Screening</span
        >) to obtain an integrated result.<br />
      </p>
      <h3 class="sub">Gene Information</h3>
      <p>
        There is a
        <span class="readmeEmp">summary of Gene</span> interested in, which
        including Gene Information and Pathway Information.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search1_1" v-lazy="search1_1" />
        <span>&nbsp;&nbsp;&nbsp;&nbsp;</span>
        <img class="helpimg-detail" alt="search1_2" v-lazy="search1_2" />
      </div>
      <h3 class="sub">Single-cell Immunity</h3>
      <p>
        In <span class="readmeEmp">Single-cell Immunity</span>, users can hover
        the point or sort the table to discover the
        <span class="readmeEmp">Cell Type Marker</span> in different cancer
        type. Moreover, users can click the tab of table to show the detail
        image of this cell type in the dataset.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search6_1" v-lazy="search6_1" />
      </div>
      <p>
        In <span class="readmeEmp">Co-expression Analysis</span>,users can
        calculate the correlation between the expression of a gene of interest
        and other genes or between the expression of the input gene pairs in
        different cell types.<br />
        In <span class="readmeEmp">Differential Expression Analysis</span>,
        users can click the tab of table for the detail information, which is
        composed of UMAP plots and barplots used to visualize the differential
        expression of the selected gene between different groups in the selected
        tab.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search6_2" v-lazy="search6_2" />
        <img class="helpimg-detail" alt="search6_3" v-lazy="search6_3" />
      </div>
      <h3 class="sub">Immunotherapy Response</h3>
      <p>
        TIGER will show the
        <span class="readmeEmp">Differential Expression Analysis</span> and
        <span class="readmeEmp">Survival Analysis</span> with clinical info. The
        scatter plot and the specific difference result table of each dataset
        will be analyzed and displayed.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search2_1" v-lazy="search2_1" />
        <img class="helpimg-detail" alt="search2_2" v-lazy="search2_2" />
        <img class="helpimg-detail" alt="search2_3" v-lazy="search2_3" />
      </div>
      <h3 class="sub">Response Signature</h3>
      <p class="tab">
        In <span class="readmeEmp">AUC Matrix</span> and
        <span class="readmeEmp">Survival Matrix</span>, users can compare the
        performance of their own biomarkers with known immunotherapy response
        signature using the gene expression data with immunotherapy clinical
        information
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search5_2" v-lazy="search5_2" />
        <img class="helpimg-detail" alt="search5_3" v-lazy="search5_3" />
      </div>
      <p class="tab">
        In <span class="readmeEmp">Correlation Matrix</span>, users could check
        whether the genes of interest are correlated with the known
        immunotherapy response signature using the TCGA gene expression data
        without immunotherapy clinical information
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search5_1" v-lazy="search5_1" />
      </div>
      <h3 class="sub">Immune Screening</h3>
      <p>
        Gene-related CRISPER Screen and RNAi Screen information will be
        displayed in the form of a table, and you can get the dataset related
        information by clicking on the row of the table.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search4_1" v-lazy="search4_1" />
      </div>
    </div>

    <div v-show="responseshow">
      <h2 class="sub">Immunotherapy Response</h2>
      <p>
        This module provides a lot of functions for the analysis of bulk
        transcriptome gene expression data with immunotherapy clinical
        information. This module consists of four tabs including the
        <span class="readmeEmp">Overview</span>,
        <span class="readmeEmp">Differential Expression Analysis</span>,
        <span class="readmeEmp">Survival Analysis</span> and
        <span class="readmeEmp">Gene Set Query</span>.
      </p>
      <h3 class="sub">Overview</h3>
      <p>
        In the Overview tab, users can browse the data source information and
        the overview of differential expression analysis and survival analysis
        results.
      </p>
      <div align="center">
        <img alt="help2" v-lazy="help2" />
        <img alt="help2_2" v-lazy="help2_2" />
      </div>

      <h3 class="sub">Differential Expression Analysis</h3>
      <p>
        In the
        <span class="readmeEmp">Differential Expression Analysis</span> tab, two
        interactive heatmaps displaying the differentially expressed genes
        between <span class="readmeEmp">responder and non-responder</span> or
        between <span class="readmeEmp">pre- and post-therapy</span> are
        presented to allow users to explore the immunotherapy response
        biomarkers and resistance mechanisms. <br />
        By clicking a cell of the heatmap, users will obtain the detail
        information of differential expression in the selected dataset, which
        contains a <span class="readmeEmp">boxplot</span> is presented to
        visualize the differential expression and a
        <span class="readmeEmp">table</span> displayed to allow users to compare
        the performance of the selected gene with the known immunotherapy
        prediction signature.
      </p>
      <div align="center">
        <img alt="help3" v-lazy="help3" />
      </div>
      <div align="center">
        <img width="60%" alt="help4" v-lazy="help4" />
      </div>

      <h3 class="sub">Survival Analysis</h3>
      <p>
        The <span class="readmeEmp">Survival Analysis</span> tab presents an
        interactive heatmap displaying the survival analysis results to allow
        users to evaluate the immunotherapy response biomarkers. The detail
        information will be presented when users click a cell in the interactive
        heatmap. In the detail information, a KM plot is provided for
        visualization. Moreover, users can adjust the survival analysis
        parameters and compare the performance with known signatures
      </p>
      <div align="center">
        <img alt="help5" v-lazy="help5" />
      </div>
      <div align="center">
        <img width="60%" alt="help11" v-lazy="help11" />
      </div>
      <h3 class="sub">Gene Set Query</h3>
      <p>
        To allow users to evaluate their own gene signature using our collected
        immunotherapy gene expression datasets, we designed the
        <span class="readmeEmp">Gene Set Query</span>
        tab
      </p>
      <div align="center">
        <img
          width="150%"
          class="helpimg-detail"
          alt="response3_1"
          v-lazy="response3_1"
        />
      </div>
    </div>

    <div v-show="signatureshow">
      <h2 class="sub">Response Signature</h2>
      <p class="tab">
        The <span class="readmeEmp">Response Signature</span> module contains
        analysis functions for exploring cancer immunotherapy using known
        immunotherapy response signatures collected from public literature.
      </p>
      <h3 class="sub">Overview</h3>
      <p class="tab">
        Use the <span class="readmeEmp">Overview</span> table of
        <span class="readmeEmp">Response Signature</span> to show the degree of
        correlation between each response signature and immune response (AUC is
        obtained from the analysis of all immune response data collected).<br />
        Click on the detail button in the table, and TIGER will display the
        related information of changing Response Signature.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="signature1_1" v-lazy="signature1_1" />
        <img class="helpimg-detail" alt="signature1_2" v-lazy="signature1_2" />
      </div>
      <h3 class="sub">Biomarker Analysis</h3>
      <p class="tab">
        In <span class="readmeEmp">AUC Matrix</span> and
        <span class="readmeEmp">Survival Matrix</span>, users can compare the
        performance of their own biomarkers with known immunotherapy response
        signature using the gene expression data with immunotherapy clinical
        information
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search5_2" v-lazy="search5_2" />
        <img class="helpimg-detail" alt="search5_3" v-lazy="search5_3" />
      </div>
      <p class="tab">
        In <span class="readmeEmp">Correlation Matrix</span>, users could check
        whether the genes of interest are correlated with the known
        immunotherapy response signature using the TCGA gene expression data
        without immunotherapy clinical information
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="search5_1" v-lazy="search5_1" />
      </div>

      <h3 class="sub">Response Prediction</h3>
      <p>
        In <span class="readmeEmp">Response Prediction</span>, users can predict
        the patient immunotherapy response by applying published gene signatures
        to the user-provided baseline gene expression profiles.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="signature2_1" v-lazy="signature2_1" />
      </div>
      <!-- <div align="center">
        <img class="helpimg-detail" alt="signature2_2" v-lazy="signature2_2" />
      </div> -->
    </div>

    <div v-show="singcellshow">
      <h2 class="sub">Single-cell Immunity</h2>
      <p>
        This module provides users with
        <span class="readmeEmp">plentiful scRNA-seq analysis</span> functions in
        six tabs including the <span class="readmeEmp">Overview</span>,
        <span class="readmeEmp">Cell Type Marker</span>,
        <span class="readmeEmp">Differential Expression Analysis</span>,
        <span class="readmeEmp">Correlation Analysis</span>,
        <span class="readmeEmp">Trajectory Analysis</span> and
        <span class="readmeEmp">Cell-Cell Communication</span> tabs.<br />
        Users can click the dataset for detail information.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell0" v-lazy="singcell0" />
      </div>
      <h3 class="sub">Overview</h3>
      <p>
        Users will obtain the dataset source, cell number and cell type
        information in the <span class="readmeEmp">Overview</span> tab, which
        presents a table showing the dataset information, and UMAP plots showing
        the pre-analyzed clustering results for all cells, T cells, CD4 cells,
        CD8 cells, B cells, and Myeloid cells, respectively
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell1_1" v-lazy="singcell1_1" />
      </div>

      <h3 class="sub">Cell Type Marker / Differential Expression Analysis</h3>
      <p>
        In the <span class="readmeEmp">Cell Type Marker</span> tab, an
        interactive heatmap in a sub-tab showing the gene expression fold
        changes between a cell cluster and other cells is presented to allow
        users to explore the markers and functions of each cell type.<br />
        In the
        <span class="readmeEmp">Differential Expression Analysis</span> tab, an
        interactive heatmap in a sub-tab showing the differential expression of
        genes in each cell type between tumor and normal or between
        immunotherapy responders and non-responders is presented to allow users
        to explore the anti-tumor immunity and immunotherapy biomarkers.<br />
        In the interactive heatmap, a selection box is provided to allow users
        to quickly locate main lineage cell types of interest, and a text box is
        provided to allow users to search genes of interest. By clicking a cell,
        users can obtain the detail information below the heatmap.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell2_1" v-lazy="singcell2_1" />
        <img class="helpimg-detail" alt="singcell3_1" v-lazy="singcell3_1" />
      </div>

      <h3 class="sub">Co-expression Analysis</h3>
      <p>
        In the <span class="readmeEmp">Co-expression Analysis</span> tab, users
        can calculate the correlation between the expression of a gene of
        interest and other genes or between the expression of the input gene
        pairs in different cell types.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell4_1" v-lazy="singcell4_1" />
      </div>

      <h3 class="sub">Trajectory Analysis</h3>
      <p>
        In the <span class="readmeEmp">Trajectory Analysis</span> tab, users can
        obtain the expression of the genes of interest in the pseudotemporal
        ordering cells inferred by Monocle 2.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell5_1" v-lazy="singcell5_1" />
      </div>
      <h3 class="sub">Cell-Cell Communication</h3>
      <p>
        The <span class="readmeEmp">Cell-Cell Communication</span> tab allows
        users to obtain the crosstalk between different cell types inferred by
        receptor-ligand expression.
      </p>
      <div align="center">
        <img class="helpimg-detail" alt="singcell6_1" v-lazy="singcell6_1" />
      </div>
    </div>

    <div v-show="screenshow">
      <h2 class="sub">Immune Screening</h2>
      <p>
        The <span class="readmeEmp">Immune Screening</span> module presents an
        interactive heatmap showing the in vitro/in vivo immunotherapy
        experiment results from public CRISPR or shRNA screening studies.<br />
        By click the cell of the heatmap, users can obtain the corresponding
        screen data information and gene-related drug information.
      </p>
      <div align="center">
        <img alt="help10" v-lazy="help10" />
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
      help2_2: require("../assets/help2-2.png"),
      help3: require("../assets/help3.png"),
      help4: require("../assets/help4.png"),
      help5: require("../assets/help5.png"),
      help6: require("../assets/help6.png"),
      help7: require("../assets/help7.png"),
      help8: require("../assets/help8.png"),
      help9: require("../assets/help9.png"),
      help10: require("../assets/help10.png"),
      help11: require("../assets/help11.png"),
      helphome: require("../assets/help-home.png"),
      response3_1: require("../assets/response-3-1.png"),
      search1_1: require("../assets/search-1-1.png"),
      search1_2: require("../assets/search-1-2.png"),
      search2_1: require("../assets/search-2-1.png"),
      search2_2: require("../assets/search-2-2.png"),
      search2_3: require("../assets/search-2-3.png"),
      search4_1: require("../assets/search-4-1.png"),
      search5_1: require("../assets/search-5-1.png"),
      search5_2: require("../assets/search-5-2.png"),
      search5_3: require("../assets/search-5-3.png"),
      search6_1: require("../assets/search-6-1.png"),
      search6_2: require("../assets/search-6-2.png"),
      search6_3: require("../assets/search-6-3.png"),
      signature1_1: require("../assets/signature-1-1.png"),
      signature1_2: require("../assets/signature-1-2.png"),
      signature2_1: require("../assets/signature-2-1.png"),
      signature2_2: require("../assets/signature-2-2.png"),
      signature3_1: require("../assets/signature-3-1.png"),
      singcell0: require("../assets/singcell-0.png"),
      singcell1_1: require("../assets/singcell-1-1.png"),
      singcell2_1: require("../assets/singcell-2-1.png"),
      singcell3_1: require("../assets/singcell-3-1.png"),
      singcell4_1: require("../assets/singcell-4-1.png"),
      singcell5_1: require("../assets/singcell-5-1.png"),
      singcell6_1: require("../assets/singcell-6-1.png"),
      searchshow: false,
      responseshow: false,
      signatureshow: false,
      singcellshow: false,
      screenshow: false,
    };
  },
  methods: {
    resetshow() {
      this.searchshow = false;
      this.responseshow = false;
      this.signatureshow = false;
      this.singcellshow = false;
      this.singcellshow = false;
    },
    changeshow(tabname) {
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
    goTop,
  },
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
.helpimg-main {
  width: 80%;
}
.helpimg-detail {
  width: 30%;
}
</style>
