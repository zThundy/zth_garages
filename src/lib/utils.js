
export function pad(num) {
    return num.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ",")
}

export function formatDate(date) {
    // convert date if it's a string
    if (typeof date === "string") {
        date = new Date(date)
    }

    // format to dd/MMM/yyyy HH:mm and add padding to single digit days and hours
    return `${date.getDate().toString().padStart(2, "0")}/${date.getMonth().toString().padStart(2, "0")}/${date.getFullYear()} ${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`
}