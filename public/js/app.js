document.addEventListener('DOMContentLoaded',()=>{
 const toggle=document.querySelector('.mobile-menu');const nav=document.querySelector('.main-nav');
 if(toggle&&nav){toggle.addEventListener('click',()=>{const open=nav.classList.toggle('open');toggle.setAttribute('aria-expanded',open?'true':'false');});}
});
