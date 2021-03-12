<template>
  <div class="outside">
    <el-card class="serachpage" id="helppage">
      <el-col span="22" push="1">
        <div class="main_con" id="1" ref="userinfo1">
          <h1 class="subtitle">Introduction to TIGER</h1>
          <el-divider></el-divider>
          <el-row>
            <el-col :span="12">
              <p>
                TIGER is a web-accessible portal for integrative analysis of the
                gene expression data related to tumor immunology. TIGER contains
                bulk transcriptome data for 1,144 tumor samples with
                immunotherapy clinical outcome and 11,057 tumor/normal samples
                from TCGA, and single cell transcriptome data for 2,116,945
                cells of 655 samples, among which 119,039 cells of
                63 samples have immunotherapy clinical data. Besides, we also
                collected eight CRISPR and two shRNA screening data from studies
                identifying genes responsible of anticancer immune response.
                Moreover, we collected 11 gene signatures that could be
                potentially used to predict the immunotherapy response from
                public literature.
              </p>
            </el-col>
            <el-col :span="10" :offset="2">
              <img alt="help" v-lazy="home" />
            </el-col>
          </el-row>
        </div>

        <div class="main_con" id="4" ref="userinfo4">
          <h1 class="subtitle">Usage of TIGER</h1>
          <el-divider></el-divider>
          <p>
            TIGER is composed of four major modules, including Immunotherapy
            Response, Response Signature, Single-cell Immunity and Immune
            Screening with a Quick Search module.
          </p>
        </div>
        <el-row>
          <el-col :span="4" :push="0">
            <el-card
              shadow="hover"
              class="box-card"
              @click.native="handleEdit('search')"
            >
              <div slot="header" class="clearfix" style="text-align: center">
                <span class="homedesrc">Quick<br />Search</span>
                <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
              </div>
              <div style="text-align: center">
                <img height="150px" src="../assets/homesearch.png" />
              </div>
            </el-card>
          </el-col>
          <el-col :span="4" :push="1">
            <el-card
              shadow="hover"
              class="box-card"
              @click.native="handleEdit('singcell')"
            >
              <div slot="header" class="clearfix" style="text-align: center">
                <span class="homedesrc">Single Cell Immunity</span>
                <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
              </div>
              <div style="text-align: center">
                <img height="150px" src="../assets/homesc.png" />
              </div>
            </el-card>
          </el-col>
          <el-col :span="4" :push="2">
            <el-card
              shadow="hover"
              class="box-card"
              @click.native="handleEdit('response')"
            >
              <div slot="header" class="clearfix" style="text-align: center">
                <span class="homedesrc">Immunotherapy Response</span>
                <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
              </div>
              <div style="text-align: center">
                <img height="150px" src="../assets/homeir.png" />
              </div>
            </el-card>
          </el-col>
          <el-col :span="4" :push="3">
            <el-card
              shadow="hover"
              class="box-card"
              @click.native="handleEdit('signature')"
            >
              <div slot="header" class="clearfix" style="text-align: center">
                <span class="homedesrc">Response Signature</span>
                <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
              </div>
              <div style="text-align: center">
                <img height="150px" src="../assets/homesig.png" />
              </div>
            </el-card>
          </el-col>
          <el-col :span="4" :push="4">
            <el-card
              shadow="hover"
              class="box-card"
              @click.native="handleEdit('screen')"
            >
              <div slot="header" class="clearfix" style="text-align: center">
                <span class="homedesrc">Immune Screening</span>
                <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
              </div>
              <div style="text-align: center">
                <img width="150px" src="../assets/homeis.png" />
              </div>
            </el-card>
          </el-col>
        </el-row>
        <v-helpdetail ref="helpdetail" v-show="true" :tabname="detailname">
        </v-helpdetail>
      </el-col>
    </el-card>

    <goTop></goTop>
  </div>
</template>


<script>
import goTop from "./public/goTop";

export default {
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
      detailname: "",
    };
  },
  created() {
    this.$refs.helpdetail.changeshow("search");
  },
  methods: {
    handleEdit(tabname) {
      this.detailname = tabname;
      this.$refs.helpdetail.changeshow(this.detailname);
    },
  },
  components: {
    goTop,
  },
  components: {
    "v-helpdetail": () => import("./helpdetail.vue"),
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
</style>
