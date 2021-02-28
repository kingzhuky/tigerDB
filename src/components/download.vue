<template>
  <div class="detail-card">
    <br>
    <br>
    <el-card class="infor">
      <el-row >
        <el-col :push="1" :span="22">
          <p class="title">Immunotherapy Dataset</p>
        </el-col>
      </el-row>
      <el-row>
        <el-col :push="1" :span="22">
        <el-table v-loading="loading" :data="bulktable" max-height="400" stripe border style="width: 100%">
            <el-table-column property="DatasetID" label="Dataset ID" align="center" ></el-table-column>
            <!-- <el-table-column property="Dataset" label="Dataset" align="center" ></el-table-column> -->
            <el-table-column property="CancerType" label="Cancer Type" align="center" ></el-table-column>
            <!-- <el-table-column property="Therapy" label="Therapy" align="center" ></el-table-column> -->
            <!-- <el-table-column property="PMID" label="PMID" align="center">
                <template slot-scope="scope">
                  <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID"
                    target="_blank"
                    class="buttonText">{{scope.row.PMID}}</a>
                </template>
              </el-table-column> -->
            <el-table-column label="PMID" align="center" width="150%">
              <template slot-scope="scope">
                  <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="openurl('https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID)"
                  >{{scope.row.PMID}}</el-button>
              </template>
            </el-table-column>
            <!-- <el-table-column property="SampleSize" label="Sample Size" align="center" ></el-table-column> -->
            <el-table-column label="Expression Data" align="center" width="180%">
              <template slot-scope="scope">
                  <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="openurl(scope.row.response_data)"
                  >Download</el-button>
              </template>
            </el-table-column>
            <el-table-column label="Clinicial Data" align="center" width="180%">
              <template slot-scope="scope">
                  <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="openurl(scope.row.clinicaldata)"
                  >Download</el-button>
              </template>
            </el-table-column>
        </el-table>
        </el-col>
      </el-row>
    </el-card>
    <el-card class="infor">
      <el-row >
        <el-col :push="1" :span="22">
          <p class="title">Single-cell Datasets</p>
        </el-col>
      </el-row>
      <el-row>
        <el-col :push="1" :span="22">
        <el-table v-loading="loading" :data="sctable" max-height="400" stripe border style="width: 100%">
            <!-- <el-table-column property="datasetid" label="Dataset ID" align="center" ></el-table-column> -->
            <el-table-column property="datasetname" label="Dataset Name" align="center" ></el-table-column>
            <el-table-column property="cancertype" label="Cancer Type" align="center" sortable width="150%"></el-table-column></el-table-column>
            <!-- <el-table-column property="checkpointtreatment" label="Immunetherapy" align="center" ></el-table-column> -->
            <el-table-column property="glo" label="Differential Expression Analysis" align="center" width="150%"></el-table-column>
            <el-table-column property="pmid" label="PMID" align="center">
                <template slot-scope="scope">
                  <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID"
                    target="_blank"
                    class="buttonText">{{scope.row.pmid}}</a>
                </template>
              </el-table-column>
            <el-table-column property="samplenum" label="Sample Size" align="center"></el-table-column>
            <el-table-column property="cellnum" label="Cell Number" align="center"></el-table-column>
            <el-table-column label="Cell Marker Matrix" align="center" width="180%">
              <template slot-scope="scope">
                  <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="handleEdit('scmarkermat_' + scope.row.datasetid + '.tsv')"
                  >Download</el-button>
              </template>
            </el-table-column>
            <el-table-column label="Differential Expression Matrix" align="center" width="180%">
              <template slot-scope="scope">
                  <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  :disabled="scope.row.glo == 'Tumor'"
                  @click="handleEdit('scdiffmat_' + scope.row.datasetid + '.tsv')"
                  >Download</el-button>
              </template>
            </el-table-column>
        </el-table>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="infor">
      <el-row >
        <el-col :push="1" :span="22">
          <p class="title">Study related to Response Signature</p>
        </el-col>
      </el-row>
      <el-row>
        <el-col :push="1" :span="22">
        <el-table v-loading="loading" :data="sigtable" max-height="400" stripe border style="width: 100%">
            <!-- <el-table-column property="SignatureID" label="Signature ID" align="center" ></el-table-column> -->
            <el-table-column property="SignatureName" label="Signature Name" align="center" ></el-table-column>
            <el-table-column property="SignatureCite" label="Signature Cite" align="center" ></el-table-column>
            <el-table-column property="Journal Info" label="Journal Info" align="center"></el-table-column>
            <el-table-column property="PMID" label="PMID" align="center">
                <!-- <template slot-scope="scope">
                  <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID"
                    target="_blank"
                    class="buttonText">{{scope.row.PMID}}</a>
                </template> -->
              </el-table-column>
            <el-table-column label="Article" align="center" width="300%">
              <template slot-scope="scope">
                  <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="openurl('https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID)"
                  >{{scope.row.SignatureName}}</el-button>
              </template>
            </el-table-column>
        </el-table>
        </el-col>
      </el-row>
    </el-card>
    <el-card class="infor">
      <el-row >
        <el-col :push="1" :span="22">
          <p class="title">Immune Screening Datasets</p>
        </el-col>
      </el-row>
      <el-row>
        <el-col :push="1" :span="22">
           <el-table v-loading="loading" :data="imscreentable" max-height="400" stripe border style="width: 100%">
            <!-- <el-table-column property="SignatureID" label="Signature ID" align="center" ></el-table-column> -->
            <el-table-column property="dataset_id" label="Dataset Name" align="center" ></el-table-column>
            <el-table-column property="dataset_type" label="Dataset Type" align="center" ></el-table-column>
            <el-table-column property="Cancer_type" label="Cancer Type" align="center"></el-table-column>
            <el-table-column property="PMID" label="PMID" align="center">
                <!-- <template slot-scope="scope">
                  <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID"
                    target="_blank"
                    class="buttonText">{{scope.row.PMID}}</a>
                </template> -->
              </el-table-column>
            <el-table-column label="Article" align="center" width="300%">
              <template slot-scope="scope">
                  <el-button
                  id="immusignatureplot"
                  icon="el-icon-s-marketing"
                  @click="openurl('https://pubmed.ncbi.nlm.nih.gov/'+scope.row.PMID)"
                  >{{scope.row.dataset_id}}</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>
    </el-card>

  </div>
</template>


<script>
export default {
  data() {
    return {
      validationData: [
        {
          id: "1",
          Species: "Human",
          Assembly: "hg38",
          Data: "Validated Target",
          file: "validation_human_download.zip",
        },
        {
          id: "2",
          Species: "Human",
          Assembly: "hg38",
          Data: "Potential Target (Binding)",
          file: "binding_human_download.zip",
        },
        {
          id: "3",
          Species: "Human",
          Assembly: "hg38",
          Data: "Potential Target (Perturbation)",
          file: "perturbated_human_download.zip",
        },
        {
          id: "4",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Validated Target",
          file: "validation_human_download.zip",
        },
        {
          id: "5",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Potential Target (Binding)",
          file: "",
        },
        {
          id: "6",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Potential Target (Perturbation)",
          file: "perturbated_mouse_download.zip",
        },
      ],
      bulktable: [],
      sctable: [],
      sigtable: [],
      imscreentable: [],
      loading: true,
    };
  },
  created(){
    this.getBlukTable()
    this.getScTable()
    this.getSigTable()
    this.getImscreenTable()
    // console.log(this.validationData)
  },
  methods: {
    handleEdit(file) {
      var index = "/tiger/Download/"
      window.open(index + file);
    },
    openurl(url){
      window.open(url);
    },
    // getBlukTable() {
    //   this.$http.get("/tiger/bulkdownload.json").then((res) => {
    //     this.bulktable = res.data;
    //     console.log(this.bulktable)
    //     this.loading = false;
    //     // console.log(this.sigtable)
    //   });
    //   // console.log(this.sigtable)
    // },
    getBlukTable() {
      this.loading = true;
      this.$http
        .get("/tiger/downloadtable.php", {
          params: {
            table: "downloadtable"
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            this.bulktable = res.data.tabledata;
            // console.log(this.bulktable)
            this.loading = false;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
    getScTable() {
      this.loading = true;
      this.$http
        .get("/tiger/downloadtable.php", {
          params: {
            table: "scrnaseqinfo"
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            this.sctable = res.data.tabledata;
            this.loading = false;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
    getSigTable() {
      this.loading = true;
      this.$http
        .get("/tiger/downloadtable.php", {
          params: {
            table: "siginfo"
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            this.sigtable = res.data.tabledata;
            // console.log(this.sigtable)
            this.loading = false;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
    getImscreenTable() {
      this.loading = true;
      this.$http
        .get("/tiger/downloadtable.php", {
          params: {
            table: "immunescreenartle"
          }
        })
        .then(res => {
          if (res.data.status === 200) {
            this.imscreentable = res.data.tabledata;
            // console.log(this.imscreentable)
            this.loading = false;
          }
        })
        .catch(error => {
          console.log(error);
        });
    },
  },
  components: {},
};
</script>

<style>
/* #immusignatureplot {
  width: 80%;
  align-content: center;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
} */
.title {
  color: rgb(20, 146, 140);
  font-size: 30px;
}
.el-row {
  margin-top: 30px;
  margin-bottom: 20px;
}
.el-col {
  border-radius: 20px;
}
</style>
