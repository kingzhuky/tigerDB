<template>
  <div>
    <el-card id="result" class="outside">
      <div class="contactCard">
        <h2 id="people">Zhixiang Zuo</h2>
        <i id="mail" class="el-icon-message" />
        <a href="mailto:zuozhx@sysucc.org.cn" id="mail">zuozhx@sysucc.org.cn</a>
        <p></p>
        <i id="style">Associate Professor of Cancer Genomics</i>
        <p id="address">
          Cancer Center, Sun Yat-sen University, Guangzhou 510060, China
        </p>
      </div>
    </el-card>
  </div>
</template>


<script>
export default {
  data() {
    return {
      toCity: "Contact Us",
    };
  },
};
</script>

<style>
.contactCard {
  padding: 30px !important;
  margin: 30px 30px !important;
  background-color: #f5f5f5 !important;
  border-left: 8px solid rgb(20, 146, 140) !important;
}

#people {
  color: rgb(20, 146, 140) !important;
  font-size: 30px !important;
}

#mail {
  font-size: 20px !important;
  font-size: 20px !important;
  color: rgb(20, 146, 140) !important;
}

#style {
  font-weight: bold !important;
  font-size: 20px !important;
}

#address {
  margin: "10px 0" !important;
  font-size: 20px !important;
}
</style>