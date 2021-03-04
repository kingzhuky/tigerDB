<template>
  <div class="detail-card">
    <br />
    <br />
    <el-card class="infor">
      <el-row>
        <el-col :push="1" :span="22">
          <p class="title">Data Statistics</p>
          
        </el-col>
      </el-row>
      <el-row>
        <el-col :push="1" :span="22">
          <p class="title">Users Statistics</p>
          <br />
          <iframe
            width="1150"
            height="450"
            src="https://datastudio.google.com/embed/reporting/d369f04b-d4e9-4587-92d3-9f2f9f644e9e/page/NT64B"
            frameborder="0"
            style="border: 0"
            allowfullscreen
          ></iframe>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>


<script>
export default {
  data() {
    return {};
  },
  created() {},
  methods: {},
  components: {},
};
</script>

<style>
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
