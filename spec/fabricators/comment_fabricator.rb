Fabricator(:comment) do
  comment { 'Lorem Ipsum is simply dummy text...' }
  commentable! { Fabricate(:protip) }
end
