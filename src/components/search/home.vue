<template>
  <div>
    <el-card id="readmeCard">
      <el-row id="readme">Readme:</el-row>
      Users can quickly obtain the
      <span class="readmeEmp">comprehensive analysis</span> results of the above
      four modules by searching a gene of interest.
    </el-card>
    <div class="serachpage">
      <el-card class="box-card3" id="searchpart">
        <el-row class="searchrow">
          <el-col :span="8" :offset="6" id="homeInput">
            <el-autocomplete
              v-model="seargene"
              placeholder="Please Input A Gene Symbol (e.g. PDCD1 or CXCL13)"
              :fetch-suggestions="querySearchAsync"
            ></el-autocomplete>
          </el-col>
          <el-col :span="4">
            <el-button id="homebt" @click="submsearch(seargene)" :disabled="isDisable"
              >Search</el-button
            >
          </el-col>
        </el-row>
        <br />
      </el-card>
    </div>
    <div id="homecard">
      <el-card v-show="homeShow">
        <div>
          <el-tabs
            v-model="activeName"
            type="card"
            @tab-click="handleClick"
            stretch
            class="tigtable"
          >
            <el-tab-pane label="Gene Information" name="generalInformation">
              <component
                :is="generalInformationVue"
                ref="generalInformationVueRef"
                :seargene="seargene"
              ></component>
            </el-tab-pane>

            <el-tab-pane label="Single-Cell Immunity" name="singleCellImmunity">
              <component
                :is="singleCellImmunityVue"
                ref="singleCellImmunityVueRef"
                :seargene="seargene"
              ></component>
            </el-tab-pane>

            <el-tab-pane label="Immunotherapy Response" name="immuneResponse">
              <component
                :is="immuneResponseVue"
                ref="immuResponseVueRef"
                :seargene="seargene"
              ></component>
            </el-tab-pane>

            <el-tab-pane label="Signature Analysis" name="signature">
              <component
                :is="signatureVue"
                ref="immuSignatureRef"
                :gene="seargene"
              ></component>
            </el-tab-pane>

            <el-tab-pane label="Immune Screening" name="immuneScreening">
              <component
                :is="immuneScreeningVue"
                ref="immuneScreeningVueRef"
                :seargene="seargene"
              ></component>
            </el-tab-pane>
          </el-tabs>
        </div>
      </el-card>
    </div>
  </div>
</template>


<script>


const wersignature = (resolve) => require(["./signature.vue"], resolve);
//const wergeneralInformation = "./generalInformation.vue";
const werimmuneScreening = (resolve) =>
  require(["./immuneScreening.vue"], resolve);
//const wersignature = () => import('@/components/immuneSignatureTable')
import wercelltype from "./singleCell/singleCellImmunity.vue";
import werimmuneResponse from "./immuneResponse.vue";
import wergeneralInformation from "./generalInformation.vue";

export default {
  data() {
    return {
      genesug: "m6a2target/genesug",
      homeShow: true,
      isActive: true,
      restaurants: [],
      showSnackbar: false,
      seargene: "",
      activeName: "generalInformation",
      singleCellImmunityVue: "",
      immuneScreeningVue: "",
      immuneResponseVue: "",
      signatureVue: "",
      generalInformationVue: "",
    };
  },
  created() {
    this.generalInformationVue = wergeneralInformation;
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      if (to.params.gene !== undefined && to.params.gene.length !== 0) {
        vm.seargene = to.params.gene;
        vm.submsearch(to.params.gene);
      }
    });
  },
  // mounted() {
  //   if (this.$route.params.gene !== undefined) {
  //     this.seargene = this.$route.params.gene;
  //     this.submsearch();
  //   }
  // },

  methods: {
    handleClick(tab) {
      this.checkVue(tab.name);
    },

    checkVue(name) {
      switch (name) {
        case "generalInformation":
          this.generalInformationVue = wergeneralInformation;
          break;
        case "immuneResponse":
          this.immuneResponseVue = werimmuneResponse;
          this.$refs.immuResponseVueRef.plot();
          break;
        case "singleCellImmunity":
          this.singleCellImmunityVue = wercelltype;
          this.$refs.singleCellImmunityVueRef.plot();
          break;
        case "immuneScreening":
          this.immuneScreeningVue = werimmuneScreening;
          this.$refs.immuneScreeningVueRef.plot();
          break;
        case "signature":
          this.signatureVue = wersignature;
          this.$refs.immuSignatureRef.plot();
          break;
      }
    },
    submsearch(gene) {
      console.log(gene)
      if (this.seargene == "") {
        alert("Please input Gene");
      } else {
        this.homeShow = true;
        this.activeName = "generalInformation";
        this.$refs.generalInformationVueRef.getdatagene(gene);
        this.$refs.generalInformationVueRef.tableDetail(gene);
        this.$refs.generalInformationVueRef.getdataReactome(gene);
      }
    },

    querySearchAsync(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.seargene,
            species: "Human",
          },
        })
        .then((res) => {
          cb(res.data.datasetinfo);
        });
    },
  },

  components: {
    generalInformationVue: wergeneralInformation,
  },
};
</script>

<style>
.textitem {
  padding-bottom: 20px;
}
.card-title {
  text-align: left;
  padding-left: 10px;
  border-left: 5px solid rgb(20, 146, 140);
  color: rgb(20, 146, 140);
  font-size: 1.5em;
  margin-bottom: 15px;
  text-transform: capitalize;
}
#readme {
  color: rgb(20, 146, 140);
  font-weight: bold;
  font-size: 20px;
  padding-bottom: 10px;
}

div#readmeCard {
  font-size: 16px;
  line-height: 22px;
  border-color: rgb(20, 146, 140);
  margin-bottom: 20px;
}
#homebt {
  background-color: rgb(20, 146, 140) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}

#seargene {
  width: 105px;
}

#searchpart .el-input {
  position: relative !important;
  font-size: 14px !important;
  /* display: inline-block !important; */
  width: 100% !important;
}

.searchrow {
  padding-top: 25px !important;
}

.tableSearch {
  margin-top: 50px !important;
  border-radius: 15px !important;
}

#noresu {
  text-align: center;
  font-size: 30px;
  color: #f89191;
}

.box-card3 {
  border-radius: 15px !important;
}

#searchpart .demonstration {
  text-align: right !important;
  vertical-align: middle !important;
  float: left !important;
  color: #606266 !important;
  line-height: 40px !important;
  box-sizing: border-box !important;
  width: 100% !important;
  font-size: 22px !important;
  font-weight: bold !important;
}

#serachbt {
  font-size: 24px !important;
  margin-left: 70px !important;
}

#tab-generalInformation,
#tab-immuneResponse,
#tab-singleCellImmunity,
#tab-immuneResponse,
#tab-immuneScreening,
#tab-signature {
  font-size: 20px;
  height: 55px;
  padding: 10px;
  font-weight: bold !important;
}
#homeInput .el-autocomplete {
  width: 100%;
}
</style>