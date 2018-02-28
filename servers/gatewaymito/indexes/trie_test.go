package indexes

import "testing"
import "gopkg.in/mgo.v2/bson"

func TestSize(t *testing.T) {
	trie := NewTrie()

	if trie.Size() != 1 {
		t.Errorf("trie size is invalid, expected %v got %v", 1, trie.Size())
	}
}

func TestAdd(t *testing.T) {
	trie := NewTrie()
	size := 1

	objectID1 := bson.NewObjectId()
	objectID2 := bson.NewObjectId()
	objectID3 := bson.NewObjectId()
	objectID4 := bson.NewObjectId()
	objectID5 := bson.NewObjectId()
	objectID6 := bson.NewObjectId()
	objectID7 := bson.NewObjectId()

	kvPairs := map[string]bson.ObjectId{
		"baby":  objectID1,
		"bad":   objectID2,
		"badly": objectID3,
		"bank":  objectID4,
		"box":   objectID5,
		"dad":   objectID6,
		"dance": objectID7,
	}

	for k, v := range kvPairs {
		trie.Add(k, v)
		size++

		if trie.Size() != size {
			t.Errorf("trie size is invalid. expected %v got %v", size, trie.Size())
		}
	}
}

func TestDelete(t *testing.T) {
	trie := NewTrie()
	size := 1

	objectID1 := bson.NewObjectId()
	objectID2 := bson.NewObjectId()
	objectID3 := bson.NewObjectId()
	objectID4 := bson.NewObjectId()
	objectID5 := bson.NewObjectId()
	objectID6 := bson.NewObjectId()
	objectID7 := bson.NewObjectId()

	kvPairs := map[string]bson.ObjectId{
		"baby":  objectID1,
		"bad":   objectID2,
		"badly": objectID3,
		"bank":  objectID4,
		"box":   objectID5,
		"dad":   objectID6,
		"dance": objectID7,
	}

	for k, v := range kvPairs {
		trie.Add(k, v)
		size++

		if trie.Size() != size {
			t.Errorf("trie size is invalid. expected %v got %v", size, trie.Size())
		}
	}

	// Delete an existing pair
	if trie.Delete("baby", objectID1) == false {
		t.Error("trie delete is invalid. expected true got false")
	}

	// Delete a key that shouldnt exist
	if trie.Delete("baby", objectID1) == true {
		t.Error("trie delete is invalid. Expected false, key should not exist")
	}

	// Delete an existing pair
	if trie.Delete("bad", objectID2) == false {
		t.Error("trie delete is invalid. expected true got false")
	}

	// Delete an existing pair
	if trie.Delete("badly", objectID3) == false {
		t.Error("trie delete is invalid. expected true got false")
	}

	// Delete an existing pair
	if trie.Delete("bank", objectID4) == false {
		t.Error("trie delete is invalid. expected true got false")
	}

	// Delete a key that shouldnt exist
	if trie.Delete("badly", objectID3) == true {
		t.Error("trie delete is invalid. Expected false, key should not exist")
	}
}

func TestChildren(t *testing.T) {
	trie := NewTrie()
	size := 1

	objectID1 := bson.NewObjectId()
	objectID2 := bson.NewObjectId()
	objectID3 := bson.NewObjectId()
	objectID4 := bson.NewObjectId()
	objectID5 := bson.NewObjectId()
	objectID6 := bson.NewObjectId()
	objectID7 := bson.NewObjectId()
	objectID8 := bson.NewObjectId()

	kvPairs := map[string]bson.ObjectId{
		"baby":  objectID1,
		"bad":   objectID2,
		"badly": objectID3,
		"bank":  objectID4,
		"box":   objectID5,
		"dad":   objectID6,
		"dance": objectID7,
	}

	for k, v := range kvPairs {
		trie.Add(k, v)
		size++

		if trie.Size() != size {
			t.Errorf("trie size is invalid. expected %v got %v", size, trie.Size())
		}
	}

	results := trie.DFSChildren("ba", 4)
	correctResults := []bson.ObjectId{objectID1, objectID2, objectID3, objectID4}
	for i := range results {
		if results[i] != correctResults[i] {
			t.Errorf("trie children do not match: got %v but expected %v", results, correctResults)
		}
	}

	results = trie.DFSChildren("", 4)
	correctResults = []bson.ObjectId{objectID1, objectID2, objectID3, objectID4}
	for i := range results {
		if results[i] != correctResults[i] {
			t.Errorf("trie children do not match: got %v but expected %v", results, correctResults)
		}
	}

	results = trie.DFSChildren("", 1)
	correctResults = []bson.ObjectId{objectID1}
	for i := range results {
		if results[i] != correctResults[i] {
			t.Errorf("trie children do not match: got %v but expected %v", results, correctResults)
		}
	}

	results = trie.DFSChildren("dad", 1)
	correctResults = []bson.ObjectId{objectID6}
	for i := range results {
		if results[i] != correctResults[i] {
			t.Errorf("trie children do not match: got %v but expected %v", results, correctResults)
		}
	}
	trie.Add("dad", objectID8)
	results = trie.DFSChildren("dad", 2)
	correctResults = []bson.ObjectId{objectID6, objectID8}
	for i := range results {
		if results[i] != correctResults[i] {
			t.Errorf("trie children do not match: got %v but expected %v", results, correctResults)
		}
	}

}
