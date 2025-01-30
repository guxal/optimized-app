class NotificationService {
  constructor() {
    this.sockets = [];
  }

  registerSocket(socket) {
    this.sockets.push(socket);
    socket.on("disconnect", () => {
      this.sockets = this.sockets.filter((s) => s !== socket);
    });
  }

  notify(message) {
    this.sockets.forEach((socket) => socket.emit("notification", message));
  }
}

module.exports = NotificationService;
