const API_URL = "";

const chatBox = document.getElementById("chat-box");

const questionInput = document.getElementById("question");

questionInput.addEventListener("keydown", function(event) {

    if (event.key === "Enter" && !event.shiftKey) {

        event.preventDefault();

        askQuestion();
    }
});

function addMessage(text, sender) {

    const messageDiv = document.createElement("div");

    messageDiv.classList.add("message");

    messageDiv.classList.add(sender);

    messageDiv.innerHTML = text;

    chatBox.appendChild(messageDiv);

    chatBox.scrollTop = chatBox.scrollHeight;

    return messageDiv;
}

async function askQuestion() {

    const question = questionInput.value.trim();

    if (!question) return;

    addMessage(question, "user");

    questionInput.value = "";

    const loadingMessage = addMessage(
        "🤖 Dejame pensar...",
        "ai"
    );

    try {

        const response = await fetch(API_URL + "/ask", {

            method: "POST",

            headers: {
                "Content-Type": "application/json"
            },

            body: JSON.stringify({
                question: question
            })
        });

        const data = await response.json();

        loadingMessage.innerHTML = data.answer;

    } catch (error) {

        loadingMessage.innerHTML =
            "❌ Error calling AI service";
    }
}