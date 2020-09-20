// Instruction from https://materializecss.com/auto-init.html to initialize
M.AutoInit();

// Instruction from https://materializecss.com/navbar.html
document.addEventListener("DOMContentLoaded", function() {
  var elems = document.querySelectorAll(".sidenav");
  var instances = M.Sidenav.init(elems, {});

  var elems = document.querySelectorAll(".carousel");
  var instances = M.Carousel.init(elems, {fullWidth:true,
                                         indicators:true});
});



