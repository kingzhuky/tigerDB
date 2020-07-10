<template>
  <div class="outside">
    <div class="section">
      <el-row>
        <el-col :span="14">
          <el-row id="homeinbt">
            <el-col :span="22" :offset="2">
              <p class="hometitle">About TIGER</p>
              <p class="homedesrc">
                Immunotherapy is a promising cancer treatment method that helps the immune system defense against cancer. Benefitting from immunotherapy, patients with melanoma and other cancers may survive for a long time, but still only a small fraction of cancer patients respond to immunotherapy. Therefore, although considerable progress has been achieved, much effort is still needed to understand the mechanisms of immunotherapy response and to discover effective biomarkers of response and resistance. Recent high-throughput transcriptome profiling data available in tumor immunology studies provides valuable resources in this regard. Particularly, recent single cell transcriptome studies provide us a deeper insight into the tumor immunology. However, a well-organized online repository of these tumor immunology related high-throughput gene expression data is still not available.
                <br />
                <br />Here, we present TIGER (http://tiger.canceromics.org/), a web-accessible and comprehensive open resource for providing the gene expression landscape of tumor immunology. Currently, TIGER contains bulk transcriptome data for 1022 samples with immunotherapy clinical outcome and 11,060 samples from TCGA, and single cell transcriptome data for 66,366 immune cells of 43 samples with immunotherapy clinical outcome and 485,168 immune cells of 151 samples without immunotherapy clinical outcome. Besides, we also collected eight CRISPR and two shRNA screening data from studies identifying genes responsible of anticancer immune response. Moreover, we collected 63 gene signatures that could be potentially used to predict the immunotherapy response from public literature.
              </p>
            </el-col>
            <br />
            <br />
            <br />
            <br />
          </el-row>
        </el-col>
        <el-col :span="9" :offset="1">
          <div id="homepic">
            <img src="../assets/home1.png" />

            <el-row>
              <el-col :span="12">
                <p class="hometitle">Quick Search</p>
              </el-col>
            </el-row>
            <el-col :span="14" id="homeInput">
              <el-autocomplete
                v-model="seargene"
                placeholder="Please Input Gene Symbol"
                :fetch-suggestions="querySearchAsync"
              ></el-autocomplete>
            </el-col>
            <el-col :span="6">
              <el-button id="homebt" @click="submsearch">Search</el-button>
            </el-col>
          </div>
        </el-col>
      </el-row>
    </div>
    <br />
    <br />
    <br />
    <div id="homecard">
      <el-card v-show="homeShow" v-loading="loading">
        <div>
          <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="werTab">
            <el-tab-pane label="Differential Expression Analysis" name="diffexp">
              <component :is="diffexpVue"></component>
            </el-tab-pane>

            <el-tab-pane label="Survival Analysis" name="survival">
              <component :is="survivalVue"></component>
            </el-tab-pane>

            <el-tab-pane label="Signature Analysis" name="signature">
              <component :is="signatureVue"></component>
            </el-tab-pane>
          </el-tabs>

          <el-table :data="tableData" max-height="600" style="width: 100%">
            <el-table-column prop="GENE_SYMBOL" align="center" border label="GENE SYMBOL"></el-table-column>
            <el-table-column prop="Condition" align="center" border label="Condition"></el-table-column>
            <el-table-column prop="Dataset" align="center" border label="Dataset"></el-table-column>
            <el-table-column prop="Cancer_Type" align="center" border label="Cancer Type"></el-table-column>
            <el-table-column
              prop="Statistical_Result"
              align="center"
              border
              label="Statistical Result"
            ></el-table-column>
            <el-table-column prop="P_Value" align="center" border label="P-Value"></el-table-column>
          </el-table>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script>
import { toTarget } from "../../static/js/utils.js";

const wersurvival = resolve => require(["./survival.vue"], resolve);
const werdiffexp = resolve => require(["./expression/home.vue"], resolve);
const wersignature = resolve => require(["./signature.vue"], resolve);

export default {
  name: "home",
  data: function() {
    return {
      homeShow: false,
      isActive: true,
      loading: true,
      restaurants: [],
      showSnackbar: false,
      seargene: "PDCD1",
      tableData: [],
      activeName: "diffexp",
      diffexpVue: "",
      survivalVue: "",
      signatureVue: ""
    };
  },
  created() {
    this.diffexpVue = werdiffexp;
  },

  methods: {
    handleClick(tab, event) {
      this.checkVue(tab.name);
    },
    checkVue(name) {
      switch (name) {
        case "diffexp":
          this.diffexpVue = werdiffexp;
          break;
        case "survival":
          this.survivalVue = wersurvival;
          break;
        case "signature":
          this.signatureVue = wersignature;
          break;
      }
    },
    //获取表格数据
    getTableData(gene) {
      toTarget(820);
      this.loading = true;
      this.$http
        .get("/tiger/home.php", {
          params: {
            gene: gene,
            type: "home"
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            this.tableData = res.data.list;
            this.loading = false;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },

    submsearch() {
      if (this.seargene == "") {
        alert("Please input Gene");
      } else {
        this.homeShow = true;
        this.getTableData(this.seargene);
      }
    },
    querySearchAsync(queryString, cb) {
      var restaurants = this.restaurants;
      var results = queryString
        ? restaurants.filter(this.createStateFilter(queryString))
        : restaurants;
      cb(results);
    },

    createStateFilter(queryString) {
      return restaurant => {
        return (
          restaurant.value.toLowerCase().indexOf(queryString.toLowerCase()) ===
          0
        );
      };
    }
  }
};
</script>

<style>
#homeInput .el-autocomplete {
  width: 100%;
}
#homebt {
  background-color: rgb(20, 146, 140) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}
#homeinbt .el-autocomplete {
  width: 100% !important;
}

.homeboxrow {
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
}

/* .section {
  padding-top: 10px;
} */

.hometitle {
  color: rgb(20, 146, 140) !important;
  font-size: 30px;
}
.homedesrc {
  font-size: 20px;
  line-height: 28px;
}
.quickSearch {
  font-size: 20px;
  font-weight: 500px;
}
div#homepic {
  padding-top: 85px;
}
div#homecard {
  padding: 10px;
}
</style>