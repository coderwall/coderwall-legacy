Fabricator(:comment) do
  comment { 'Lorem Ipsum is simply dummy text...' }
  commentable { Fabricate.build(:protip) }
  user { Fabricate.build(:user) }
end
