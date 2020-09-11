<template>
  <transition name="move3">
    <div class="detail-card">
      <div class="infor" v-loading="loading">
        <el-card v-for="gloclu in gloclures" :key="gloclu" class="overiewcard">
          <p class="card-title">{{gloclu}}</p>
          <el-row class="detailimg">
            <el-col :span="20" :offset="2">
              <p class="card-title">tSNE</p>
              <img id="singleimg" :src="'tiger/img/'+plotsres[gloclu][0]+'.png'" />
              <el-divider></el-divider>
              <p class="card-title">Differential cell fraction</p>
              <img id="singleimg" :src="'tiger/img/'+plotsres[gloclu][1]+'.png'" />
              <el-divider></el-divider>
              <img id="singleimg" :src="'tiger/img/'+plotsres[gloclu][2]+'.png'" />
            </el-col>
          </el-row>
        </el-card>
      </div>

      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";

export default {
  props: {
    gloclu: String,
    cancer: String,
    gloCluoptions: Array,
  },

  data() {
    return {
      scimmuShow: false,
      scimmuresShow: false,
      loading: true,
      crossloading: false,
      seargene: "HLA-A_CD3G",
      restaurants: [],
      crossClucoptions: [],
      crossClu: [],
      gloclures: [],
      plotsres: {},
    };
  },

  mounted() {
    this.clickPlot();
  },

  methods: {
    querySearchAsync(queryString, cb) {
      var restaurants = this.restaurants;
      var results = queryString
        ? restaurants.filter(this.createStateFilter(queryString))
        : restaurants;
      cb(results);
    },

    createStateFilter(queryString) {
      return (restaurant) => {
        return (
          restaurant.value.toLowerCase().indexOf(queryString.toLowerCase()) ===
          0
        );
      };
    },

    reset() {
      (this.gloclures = []), (this.plotsres = {});
    },

    checkdataset() {
      if (
        (Array.isArray(this.crossClu) && this.crossClu.length === 0) ||
        this.seargene.trim() === ""
      ) {
        return true;
      }
      return false;
    },

    clickPlot() {
      this.reset();
      for (let gloclu of this.gloCluoptions) {
        console.log(this.gloCluoptions);
        console.log(gloclu);
        this.Plot(this.cancer, gloclu["glo"]);
      }
    },

    Plot(cancer, gloclu) {
      var that = this;
      that.loading = true;
      this.$http
        .get("/tiger/singlecellimmu.php", {
          params: {
            cancer: cancer,
            gloclu: gloclu,
          },
        })
        .then(function (res) {
          if (res.data.status == 0) {
            that.gloclures.push(gloclu);
            that.plotsres[gloclu] = res.data.output[0].split(",");

            that.loading = false;
          }
        })
        .catch(function (res) {
          console.log(res);
        });
    },
  },

  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
.overiewcard {
  margin-top: 20px;
}
div#pane-overview {
  font-size: 16px;
}
#scummuviewer {
  margin-top: 15px;
}
div#viewerSelect {
  text-align: center;
}
#scimmubt {
  background-color: rgb(20, 146, 140) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}
#homespan {
  color: rgb(20, 146, 140) !important;
  font-size: 20px;
}

div#crossplot {
  padding-top: 40px;
}
</style>


