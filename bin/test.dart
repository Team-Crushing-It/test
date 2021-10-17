import 'dart:convert';

void main() {
// // skip 40, delete 47
//   print(isValid(
//               'Repl.it uses operational transformations to keep everyone in a multiplayer repl in sync.',
//               'Repl.it uses operational transformations.',
//               '[{"op": "skip", "count": 40}, {"op": "delete", "count": 47}]')
//           .toString() +
//       '\n'); // true

// // skip 45, delete 47
//   print(isValid(
//               'Repl.it uses operational transformations to keep everyone in a multiplayer repl in sync.',
//               'Repl.it uses operational transformations.',
//               '[{"op": "skip", "count": 45}, {"op": "delete", "count": 47}]')
//           .toString() +
//       '\n'); // false

// // skip 40, delete 47, skip 2
//   print(isValid(
//                   'Repl.it uses operational transformations to keep everyone in a multiplayer repl in sync.',
//                   'Repl.it uses operational transformations.',
//                   '[{"op": "skip", "count": 40}, {"op": "delete", "count": 47}, {"op": "skip", "count": 2}]')
//               .toString() +
//           '\n' // false, skip past end
//       );

//delete 7, insert 12, skip 4, delete 1
  print(isValid(
                  'Repl.it uses operational transformations to keep everyone in a multiplayer repl in sync.',
                  'We use operational transformations to keep everyone in a multiplayer repl in sync.',
                  '[{"op": "delete", "count": 7}, {"op": "insert", "chars": "We"}, {"op": "skip", "count": 4}, {"op": "delete", "count": 1}]')
              .toString() +
          '\n' // true
      );

// // nada
//   print(isValid(
//                   'Repl.it uses operational transformations to keep everyone in a multiplayer repl in sync.',
//                   'Repl.it uses operational transformations to keep everyone in a multiplayer repl in sync.',
//                   '[]')
//               .toString() +
//           '\n' //true
//       );
}

bool isValid(String stale, String latest, String otJsonString) {
// Decode the json string into a list of map
  Iterable l = json.decode(otJsonString);
  List<Map<String, dynamic>> otJson =
      List<Map<String, dynamic>>.from(l.map((json) => json));

  if (otJson.isNotEmpty) {
    Result output = otJson.fold(Result(0, stale), (output, operation) {
      switch (operation['op']) {
        case 'skip':
          {
            print('skip $output count: ${operation['count']}');

            //If cursor is moved outside of string, then return empty result
            if (output.position + operation['count'].toInt() >
                output.result.length) {
              return Result.empty;
            }

            var result = output.position + operation['count'];

            return output.copyWith(
                position: result.toInt(), result: output.result);
          }
        case 'delete':
          {
            print('delete $output, count: ${operation['count']}');

            //Check to see if we are deleting something which doesn't exist
            if (output.position + operation['count'].toInt() >
                output.result.length) {
              return Result.empty;
            }

            var string = output.result;
            var split = List<String>.from(string.split(""));

            split.removeRange(output.position,
                (output.position + operation['count']).toInt());

            return output.copyWith(
                position: output.position, result: split.join());
          }
        case 'insert':
          print('insert $output, chars: ${operation['chars']}');
          {
            var splitChars = operation['chars'].toString().split("");
            var splitString = output.result.split("");

            splitString.insertAll(output.position, splitChars);

            return output.copyWith(
              //Apparently we hold our position after an insert, that's why we update it
              position: output.position + splitChars.length,
              result: splitString.join(),
            );
          }
        default:
          {
            return output;
          }
      }
    });

    // If the output matches the latest
    if (output.result == latest) {
      return true;
    }
    // else return false
    return false;
  }

  return true;
}

class Result {
  final int position;
  final String result;

  const Result(this.position, this.result);

  static const empty = Result(0, '');

  @override
  String toString() {
    return 'Position: $position, Result: $result';
  }

  Result copyWith({
    int position,
    String result,
  }) {
    return Result(
      position,
      result,
    );
  }
}
