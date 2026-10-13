// static/script.js

document.addEventListener("DOMContentLoaded", function () {
    
    // 1. Form submit hote waqt button par loading text dikhana
    const forms = document.querySelectorAll("form");
    forms.forEach(form => {
        form.addEventListener("submit", function () {
            const submitBtn = form.querySelector("button[type='submit']");
            if (submitBtn) {
                submitBtn.innerText = "Processing... Please wait...";
                submitBtn.style.backgroundColor = "#2980b9";
                submitBtn.disabled = true;
            }
        });
    });

    // 2. Dashboard input verification (Optional alert)
    const recommendForm = document.querySelector("form[action='/recommend']");
    if (recommendForm) {
        recommendForm.addEventListener("submit", function (e) {
            const skillsInput = recommendForm.querySelector("input[name='skills']").value;
            if (skillsInput.length < 3) {
                alert("Please enter more detailed skills!");
                e.preventDefault(); // Form submit rok dega agar input chota ho
            }
        });
    }
});