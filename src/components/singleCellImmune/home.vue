<template>
  <div class="outside">
    <el-card id="scimmucard">
      <el-row id="scImmuInput">
        <el-row>
          <el-col :span="16" :offset="4">
            <p class="scImmuTitle">Select A Dataset</p>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="16" :offset="4" id="homeInput">
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
                ></el-option>
              </el-option-group>
            </el-select>
          </el-col>
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
            <component 
              ref="coexpRef" 
              :CancerType="cancer"
              :gloCluoptions="gloCluoptions"
              :is="coexpVue"
            ></component>
          </el-tab-pane>
          <el-tab-pane label="Evolution Analysis" name="evolution">
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
import weroverview from './overview.vue'
// const weroverview = (resolve) => require(["./overview.vue"], resolve);
const wercoexp = (resolve) => require(["./coExp.vue"], resolve);
const werdiffexp = (resolve) => require(["./diffExp.vue"], resolve);
const wercelltype = (resolve) => require(["./celltype.vue"], resolve);
const wercrosstalk = (resolve) => require(["./crosstalk.vue"], resolve);
const werevolution = (resolve) => require(["./evolution.vue"], resolve);

export default {
  data() {
    return {
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
      cancer: "BCC",
      gloClu: "",
      canceroptions: [],
      gloCluoptions: [],
      Signatures: "",
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
          this.overviewVue = weroverview;
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
          break;
        case "crosstalk":
          this.crosstalkVue = wercrosstalk;
          this.$refs.crosstalkRef.reset();
          break;
        case "evolution":
          this.evolutionVue = werevolution;
          break;
      }
    },
  },
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