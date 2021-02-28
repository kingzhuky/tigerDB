<template>
  <div class="infor">
    <el-card v-loading="loading">
      <p class="card-title">Dataset Information</p>
      <div>
        <el-table :data="tableData" style="width: 100%">
          <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
          <el-table-column prop="title" label width="250">
            <template slot-scope="{ row: { title } }">
              <span class="csstitle" v-if="title === 'DatasetID'"
                >Dataset ID</span
              >
              <span class="csstitle" v-else-if="title === 'DatasetName'"
                >Dataset Name</span
              >
              <span class="csstitle" v-else-if="title === 'CancerType'"
                >Cancer Type</span
              >
              <span class="csstitle" v-else-if="title === 'SampleSize'"
                >Dataset Size</span
              >
              <span class="csstitle" v-else-if="title === 'ResponseSampleCount'"
                >Responder Number</span
              >
              <span
                class="csstitle"
                v-else-if="title === 'NonresponseSampleCount'"
                >Non-Responder Number</span
              >
              <span
                class="csstitle"
                v-else-if="title === 'PretherapySampleCount'"
                >Pre-therapy Sample Number</span
              >
              <span
                class="csstitle"
                v-else-if="title === 'PosttherapySampleCount'"
                >Post-therapy Sample Number</span
              >
              <span class="csstitle" v-else>{{ title }}</span>
            </template>
          </el-table-column>
          <el-table-column label>
            <template slot-scope="scope">
              <span v-if="scope.row.title === 'PMID'">
                <a
                  :href="'https://pubmed.ncbi.nlm.nih.gov/' + scope.row.value"
                  target="_blank"
                  class="buttonText"
                  >{{ scope.row.value }}</a
                >
              </span>
              <span v-else><a v-html="scope.row.value"></a></span>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>
    <el-card v-loading="detailload" class="decard">
      <p class="card-title">Gene Information</p>
      <el-table :data="geneData" style="width: 100%">
        <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
        <el-table-column
          prop="title"
          label
          style="font-weight: 700"
          width="250"
        >
          <template slot-scope="{ row: { title } }" class="csstitle">
            <span class="csstitle" v-if="title === 'Symbol'">Gene Symbol</span>
            <span class="csstitle" v-else-if="title === 'description'"
              >Description</span
            >
            <span class="csstitle" v-else-if="title === 'type_of_gene'"
              >Gene Type</span
            >
            <span class="csstitle" v-else-if="title === 'Synonyms'"
              >Aliases</span
            >
            <span class="csstitle" v-else-if="title === 'Other_designations'"
              >Summary</span
            >
            <span class="csstitle" v-else-if="title === 'GeneID'"
              >Entrez Gene</span
            >
            <span class="csstitle" v-else>{{ title }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="value" label></el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
export default {
  name: "home",
  data: function () {
    return {
      loading: true,
      tableData: [],
      geneData: [],
      detailload: true,
    };
  },

  methods: {
    //获取表格数据
    getTableData(sample) {
      this.loading = true;
      this.$http
        .get("/tiger/immunescreendetail2.php", {
          params: {
            colu: "DatasetID",
            coluvalue: sample,
            tabl: "datesetinfo",
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.tableData = res.data.list;
            this.loading = false;
          }
        })
        .catch((error) => {
          console.log(error);
        });
    },
    getGeneData(gene) {
      this.detailload = true;
      this.$http
        .get("/tiger/searchGene.php", {
          params: {
            tabl: "home_geneinfo",
            colu: "Symbol",
            coluvalue: gene,
          },
        })
        .then((res) => {
          this.geneData = res.data.list;
          this.detailload = false;
          //}
        })
        .catch((error) => {
          console.log(error);
        });
    },
  },
};
</script>

<style>
span.csstitle {
  font-weight: 700 !important;
}
</style>