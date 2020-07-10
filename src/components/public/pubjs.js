

const getColumn2 =function (tabl, mycolumn) {
  this.$http
    .get("/tiger/tablecolumn.php", {
      params: {
        tabl: tabl,
        mycolumn: mycolumn
      }
    })
    .then(res => {
      if (res.data.status === 200) {
        //console.log(res.data.list);
        return res.data.list;
      }
    })
    .catch(error => {
      console.log(error);
    });
}

export {getColumn2}