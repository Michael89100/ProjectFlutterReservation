import '../models/reservation.dart';

class MockReservationService {
  static List<Reservation> getMockReservations() {
    return [
      Reservation(
        id: "638b320c-4da6-4f16-b94a-839c47d903a4",
        nom: "Dupont",
        prenom: "Jean",
        telephone: "0123456789",
        email: "jean.dupont@email.com",
        nombreCouverts: 2,
        dateReservation: DateTime.parse("2024-01-20T00:00:00.000Z"),
        horaire: DateTime.parse("2024-01-20T20:00:00.000Z"),
        status: "en attente",
        commentaire: "Table près de la fenêtre si possible",
        createdAt: DateTime.parse("2025-01-26T14:36:25.280Z"),
        updatedAt: DateTime.parse("2025-01-26T14:36:25.280Z"),
      ),
      Reservation(
        id: "738b320c-4da6-4f16-b94a-839c47d903a5",
        nom: "Martin",
        prenom: "Sophie",
        telephone: "0987654321",
        email: "sophie.martin@email.com",
        nombreCouverts: 4,
        dateReservation: DateTime.parse("2024-01-21T00:00:00.000Z"),
        horaire: DateTime.parse("2024-01-21T19:30:00.000Z"),
        status: "acceptée",
        commentaire: "Anniversaire de mariage",
        createdAt: DateTime.parse("2025-01-25T10:20:15.180Z"),
        updatedAt: DateTime.parse("2025-01-25T11:30:25.280Z"),
      ),
      Reservation(
        id: "838b320c-4da6-4f16-b94a-839c47d903a6",
        nom: "Leroy",
        prenom: "Pierre",
        telephone: "0567891234",
        email: "pierre.leroy@email.com",
        nombreCouverts: 6,
        dateReservation: DateTime.parse("2024-01-22T00:00:00.000Z"),
        horaire: DateTime.parse("2024-01-22T18:00:00.000Z"),
        status: "refusée",
        commentaire: "Trop de monde ce soir-là",
        createdAt: DateTime.parse("2025-01-24T16:45:30.120Z"),
        updatedAt: DateTime.parse("2025-01-24T17:00:45.340Z"),
      ),
    ];
  }
} 