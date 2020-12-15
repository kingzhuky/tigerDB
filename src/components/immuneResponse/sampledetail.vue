<template>
  <div class="infor">
    <el-card v-loading="loading">
    <p class="card-title">Dataset Information</p>
    <div>
    <el-table :data="tableData" style="width: 100%" v-loading="artloading">
            <!-- <el-table-column prop="title" label width="180"></el-table-column> -->
            <el-table-column prop="title" label width="250">
              <template slot-scope="{row: {title}}">
                <span v-if="title === 'DatasetID'">Dataset ID</span>
                <span v-else-if="title === 'DatasetName'">Dataset Name</span>
                <span v-else-if="title === 'CancerType'">Cancer Type</span>
                <span v-else-if="title === 'ResponseSampleCount'">Responder Number</span>
                <span v-else-if="title === 'NonresponseSampleCount'">Non-Responder Number</span>
                <span v-else-if="title === 'PretherapySampleCount'">Pre-therapy Sample Number</span>
                <span v-else-if="title === 'PosttherapySampleCount'">Post-therapy Sample Number</span>
                <span v-else>{{title}}</span>
              </template>
            </el-table-column>
            <el-table-column label>
              <template slot-scope="scope">
                <span v-if="scope.row.title === 'PMID'">
                  <a :href="'https://pubmed.ncbi.nlm.nih.gov/'+scope.row.value"
                    target="_blank"
                    class="buttonText">{{scope.row.value}}</a>
                  </span>
                <span v-else><a v-html="scope.row.value"></a></span>
              </template>
            </el-table-column>
    </el-table>
    </div>
    </el-card>
    </div>
</template>

<script>

export default {
  name: "home",
  data: function() {
    return {
      loading: true,
      tableData: [
      ]
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
            tabl: "datesetinfo"
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
    }
  }

   
  
};
</script>

<style>

</style>