
export function pad(num) {
    return num.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ".")
}

export function formatDate(date) {
    // convert date if it's a string
    date = new Date(date)

    // format to dd/MMM/yyyy HH:mm and add padding to single digit days and hours
    const dateString = `${date.getDate().toString().padStart(2, "0")}/${(date.getMonth() + 1).toString().padStart(2, "0")}/${date.getFullYear()} ${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`
    
    console.logger("Formatted date: ", dateString)
    return dateString
}