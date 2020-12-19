<template>
  <div id='sigpage'>
    <el-card class="box-card-heatmap">
      <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="tigtable">
        <el-tab-pane label="Overview" name="sigtable">
          <component ref="sigtableRef" :is="sigtableVue"></component>
        </el-tab-pane>
        <el-tab-pane label="Custom Analysis" name="customsig">
          <component :is="customsigVue"></component>
        </el-tab-pane>
        <el-tab-pane label="Signature Correlation Matrix" name="sigcorrmat">
          <component :is="sigmatVue"></component>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script>
import sigtablepage from "./immuneSigTable.vue";
import sigcorrmat from "./immuneSignature.vue";
import sigcustompage from "./immuneSigCustom.vue";

//import { hsv2rgb, gStyle } from "../../../static/js/utils.js";

export default {
  data() {
    return {
      activeName: "sigtable",
      sigid:"SIG2",
      sigtableVue: "",
      customsigVue: "",
      sigmatVue: "",
    };
  },
  created() {
    this.sigtableVue = sigtablepage;
    // this.$ref.sigtableRef.showDetail("SIG3")
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
        case "sigcorrmat":
          this.sigmatVue = sigcorrmat;
          break;
      }
    },
  }
};
</script>

<style>
div#sigpage {
  margin-bottom: 20px;
}

#tab-sigtable,
#tab-customsig,
#tab-sigcorrmat {
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

#survivaltable th,#therapyTable th, #responseTable th {
  left: 135px !important;
  height: 270px !important;
}


</style>
