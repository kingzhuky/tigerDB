<template>
  <div id="sigpage">
    <el-card id="readmeCard">
      <el-row id="readme">Readme:</el-row>
      1. This module provides analysis functions for exploring cancer
      immunotherapy using known
      <span class="readmeEmp">immunotherapy response signatures</span> collected
      from public literature.<br />
      2. <span class="readmeEmp">Biomarker Analysis:</span> <br />
      <el-row class="tab"
        >In <span class="readmeEmp">AUC Matrix</span> and
        <span class="readmeEmp">Survival Matrix</span>, users can compare the
        performance of their own biomarkers with known immunotherapy response
        signature using the gene expression data with immunotherapy clinical
        information</el-row
      >
      <el-row class="tab"
        >In <span class="readmeEmp">Correlation Matrix</span>, users could check
        whether the genes of interest are correlated with the known
        immunotherapy response signature using the TCGA gene expression data
        without immunotherapy clinical information</el-row
      >
      3. In <span class="readmeEmp">Response Prediction</span>, users can
      predict the patient immunotherapy response by applying published gene
      signatures to the user-provided baseline gene expression profiles
    </el-card>
    <el-card class="box-card-heatmap">
      <el-tabs
        v-model="activeName"
        type="card"
        @tab-click="handleClick"
        stretch
        class="tigtable"
      >
        <el-tab-pane label="Overview" name="sigtable">
          <component
            ref="sigtableRef"
            :is="sigtableVue"
            :sigID="sigid"
          ></component>
        </el-tab-pane>
        <el-tab-pane label="Biomarker Analysis" name="biomarker">
          <component :is="biomarkerVue"></component>
        </el-tab-pane>
        <el-tab-pane label="Response Prediction" name="customsig">
          <component :is="customsigVue"></component>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script>
import sigtablepage from "./immuneSigTable.vue";
import sigbiomarker from "./immuneSigbiomarker.vue";
import sigcustompage from "./immuneSigCustom.vue";

//import { hsv2rgb, gStyle } from "../../../static/js/utils.js";

export default {
  data() {
    return {
      activeName: "sigtable",
      sigid: "SIG1",
      sigtableVue: "",
      customsigVue: "",
      biomarkerVue: "",
    };
  },
  created() {
    if (this.$route.params.sigid !== undefined) {
      this.sigid = this.$route.params.sigid;
      // console.log(this.sigid)
    }
    this.sigtableVue = sigtablepage;
    
  },
  // beforeRouteEnter(to, from, next) {
  //   next((vm) => {
  //     if (to.params.sigid !== undefined && to.params.sigid.length !== 0) {
  //       vm.sigid = to.params.sigid;
  //       vm.$ref.sigtableRef.showDetail(vm.sigid);
  //     }
  //   });
  // },
  mounted() {
    // if (this.$route.params.sigid !== undefined) {
    //   this.sigid = this.$route.params.sigid;
    //   this.$ref.sigtableRef.showDetail(this.sigid);
    // }
    // this.$ref.sigtableRef.showDetail("SIG3")
    this.sigtableVue = sigtablepage;
  },
  methods: {
    handleClick(tab, event) {
      this.checkVue(tab.name);
    },
    checkVue(name) {
      switch (name) {
        case "sigtable":
          this.sigtableVue = sigtablepage;
          break;
        case "customsig":
          this.customsigVue = sigcustompage;
          break;
        case "biomarker":
          this.biomarkerVue = sigbiomarker;
          break;
      }
    },
  },
};
</script>

<style>
.tab {
  /* display:inline-block;  */
  margin-left: 20px;
}
div#sigpage {
  margin-bottom: 20px;
}

#tab-sigtable,
#tab-customsig,
#tab-biomarker {
  font-size: 20px;
  height: 55px;
  padding: 10px;
  font-weight: bold !important;
}

.box-card-heatmap {
  width: 1380px;
  margin: 0 auto;
}
.info {
  width: 1350px;
}

#survivaltable th,
#therapyTable th,
#responseTable th {
  left: 135px !important;
  height: 270px !important;
}
</style>
