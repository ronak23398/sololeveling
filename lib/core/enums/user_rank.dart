enum UserRank {
  E, // Lowest rank
  D,
  C,
  B,
  A,
  S, // Highest rank
}

extension UserRankExtension on UserRank {
  String get displayName {
    return 'Rank $name';
  }

  String get description {
    switch (this) {
      case UserRank.E:
        return 'Beginner Hunter';
      case UserRank.D:
        return 'Novice Hunter';
      case UserRank.C:
        return 'Regular Hunter';
      case UserRank.B:
        return 'Advanced Hunter';
      case UserRank.A:
        return 'Elite Hunter';
      case UserRank.S:
        return 'National Level Hunter';
    }
  }

  String get imagePath {
    return 'assets/images/ranks/rank_${name.toLowerCase()}.png';
  }

  // Requirements for advancing to this rank
  int get requiredLevel {
    switch (this) {
      case UserRank.E:
        return 1;
      case UserRank.D:
        return 10;
      case UserRank.C:
        return 20;
      case UserRank.B:
        return 35;
      case UserRank.A:
        return 50;
      case UserRank.S:
        return 70;
    }
  }

  // Get next rank
  UserRank? get nextRank {
    switch (this) {
      case UserRank.E:
        return UserRank.D;
      case UserRank.D:
        return UserRank.C;
      case UserRank.C:
        return UserRank.B;
      case UserRank.B:
        return UserRank.A;
      case UserRank.A:
        return UserRank.S;
      case UserRank.S:
        return null; // No higher rank
    }
  }
}
