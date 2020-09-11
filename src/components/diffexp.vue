<template>
  <div class="outsideDetail">
    <div>
      <el-row class="detailRow" id="responDetailTitle">
        Differential Expression Between Responder And Non-responder
        <el-divider></el-divider>
      </el-row>

      <el-row>
        <el-col :span="10">
          <el-row>
            <i class="el-icon-setting" id="optionsIcon"></i>
            <span id="options">Options</span>
          </el-row>
          <el-row class="detail1">Response Group</el-row>
          <el-row>
            <el-col :span="12">
              <p class="Responder">Responder</p>
              <el-select
                v-model="responder"
                multiple
                placeholder="Choose at least one"
                style="width:100%"
              >
                <el-option
                  v-for="item in responseGroupOption"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                ></el-option>
              </el-select>
            </el-col>

            <el-col :span="11" :offset="1">
              <p class="Responder">Non-Responder</p>
              <el-select
                v-model="noresponder"
                multiple
                placeholder="Choose at least one"
                style="width:100%"
              >
                <el-option
                  v-for="item in noresponseGroupOption"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                ></el-option>
              </el-select>
            </el-col>
          </el-row>

          <el-row class="detail1">Log Scale</el-row>

          <el-row>
            <el-radio v-model="logScale" label="TRUE">Yes</el-radio>
            <el-radio v-model="logScale" label="FALSE">No</el-radio>
          </el-row>

          <el-row class="plot">
            <el-button id="anabt" @click="Plot" style="width:100%">Plot</el-button>
          </el-row>
        </el-col>

        <el-col :span="12" :offset="2">
          <el-row v-loading="loading" class="detailimg">
            <img :src="imgUrlWgcna" />
          </el-row>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script>
export default {
  props: ["gene", "cancer", "mergedatasets", "normalMed", "normalGene"],
  data() {
    return {
      active: 0,
      logScale: "FALSE",
      responder: ["CR", "PR"],
      noresponder: ["PD", "SD"],
      responseGroupOption: [
        {
          value: "CR",
          label: "CR",
        },
        {
          value: "PR",
          label: "PR",
        },
      ],
      noresponseGroupOption: [
        {
          value: "PD",
          label: "PD",
        },
        {
          value: "SD",
          label: "SD",
        },
      ],
      imgpath: "",
      loading: true,
      datatype: "png",
    };
  },
  methods: {
    clickPubmed(pubmed) {
      window.open("https://www.ncbi.nlm.nih.gov/pubmed/" + pubmed, "_blank");
    },

    Plot() {
      var that = this;
      that.loading = true;
      this.$http
        .get("/tiger/responseDiff.php", {
          params: {
            cancer: this.cancer.join("_"),
            gene: this.gene,
            responder: this.responder.join(","),
            noresponder: this.noresponder.join(","),
            normalMed: this.normalMed,
            normalGene: this.normalMed == "None" ? "None" : this.normalGene,
            logScale: this.logScale,
            mergedatasets: this.mergedatasets.join(","),
            datatype: this.datatype,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            that.imgpath = res.data.output[2];
            that.loading = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },
  },
  computed: {
    imgUrlWgcna: function () {
      return "tiger/img/" + this.imgpath + ".png";
    },
  },
  components: {},
};
</script>

<style>
p.checkbox {
  padding-top: 5px;
}

.signature {
  padding-left: 10px;
}

.detailRow {
  font-size: 22px;
  font-weight: bold;
}
#options {
  font-size: 20px;
  font-weight: bold;
}
#optionsIcon {
  font-size: 36px;
}
.detail1 {
  padding-top: 30px;
  padding-bottom: 10px;
  font-size: 19px;
  font-weight: bold;
}
.detail2 {
  padding-bottom: 10px;
}

.plot {
  padding-top: 30px;
}

.activeClass {
  color: #00896c;
  border-color: rgb(179, 220, 211);
  background-color: rgb(230, 243, 240);
}
.selectmore {
  font-size: 12px;
}
.Responder {
  font-size: 14px;
  font-weight: bold;
  text-align: center;
}
</style>