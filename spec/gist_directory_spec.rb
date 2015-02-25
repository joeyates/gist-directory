require "gist_directory"

RSpec.describe GistDirectory do
  let(:path) { "/foo/bar" }
  let(:path_exists) { false }
  let(:filename) { File.join(path, "baz.txt") }
  let(:gist_result) { {"id" => gist_hash} }
  let(:gist_hash) { "gist_sha1_hash" }
  let(:git) { double(Git) }
  subject { described_class.new(filename: filename) }

  before do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with(path) { path_exists }
    allow(Gist).to receive(:gist) { gist_result }
    allow(Git).to receive(:clone)
    allow(Git).to receive(:open).and_raise("Unexpected path")
    allow(Git).to receive(:open).with(path) { git }
  end

  describe "#create" do
    context "when the path doesn't exist" do
      it "creates a Gist, adding the file" do
        subject.create
        expect(Gist).to have_received(:gist).with(
          "Empty Gist", {filename: File.basename(filename), public: true}
        )
      end
    end

    context "when the path exists" do
      let(:path_exists) { true }
      let(:dot_git_path) { File.join(path, ".git") }

      before do
        allow(File).to receive(:directory?).with(dot_git_path) { dot_git_exists }
      end

      context "and contains a Git repo" do
        let(:dot_git_exists) { true }
        let(:remotes) { [double(Git::Remote, name: "origin", url: repo_url)] }
        let(:file) { double(File, puts: nil) }

        before do
          allow(File).to receive(:open).and_call_original
          allow(File).to receive(:open).with(filename, "w").and_yield(file)
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(filename) { file_exists }
          allow(git).to receive(:remotes) { remotes }
          allow(git).to receive(:add)
          allow(git).to receive(:commit)
          allow(git).to receive(:push)
        end

        context "which is a Gist repo" do
          let(:repo_url) { "git@gist.github.com:1234" }

          context "when the file doesn't exist" do 
            let(:file_exists) { false }

            it "creates the file" do
              subject.create
              expect(file).to have_received(:puts)
            end

            it "adds the file" do
              subject.create
              expect(git).to have_received(:add).with(filename)
              expect(git).to have_received(:commit)
            end
          end

          context "when the file exists" do 
            let(:file_exists) { true }

            it "fails" do
              expect do
                subject.create
              end.to raise_error(RuntimeError, /#{filename} already exists/)
            end
          end
        end

        context "which is not a Gist repo" do
          let(:repo_url) { "git@example.com:1234" }

          it "fails" do
            expect do
              subject.create
            end.to raise_error(RuntimeError, /not contain a Gist repository/)
          end
        end
      end

      context "but doesn't contain a Git repo" do
        let(:dot_git_exists) { false }

        it "fails" do
          expect do
            subject.create
          end.to raise_error(RuntimeError, /not contain a Gist repository/)
        end
      end
    end
  end
end
